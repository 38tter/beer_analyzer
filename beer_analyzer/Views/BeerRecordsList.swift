
//
//  BeerRecordsList.swift
//  beer_analyzer
//

import SwiftUI
import Foundation

struct BeerRecordsList: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var localizationService: LocalizationService
    
    @State private var beers: [BeerRecord] = []
    @State private var isLoading = false
    @State private var hasMoreData = true
    @State private var sortDescending = true // true = 降順（新しい順）, false = 昇順（古い順）
    @State private var selectedBeer: BeerRecord?
    
    let onDelete: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // ヘッダー
                VStack(spacing: 12) {
                    HStack {
                        Text(localizationService.beerRecords)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                        Text(localizationService.currentLanguage == .japanese ? "\(beers.count)件" : "\(beers.count)\(localizationService.itemsCount)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // ソートコントロール
                    HStack {
                        Text(localizationService.sortOrder)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Picker(localizationService.sortOrder, selection: $sortDescending) {
                            Text(localizationService.newest).tag(true)
                            Text(localizationService.oldest).tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: sortDescending) { newValue in
                            changeSortOrder(descending: newValue)
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                if beers.isEmpty && !isLoading {
                    // 空の状態
                    VStack(spacing: 20) {
                        Image(systemName: "wineglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text(localizationService.noRecordsYet)
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text(localizationService.startRecording)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    // ビールリスト
                    List {
                        ForEach(beers) { beer in
                            Button(action: {
                                selectedBeer = beer
                            }) {
                                BeerRecordRow(beer: beer) { idToDelete in
                                    onDelete(idToDelete)
                                    // ローカルのリストからも削除
                                    beers.removeAll { $0.id == idToDelete }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .onAppear {
                                // 無限スクロールのトリガー
                                if beer.id == beers.last?.id && hasMoreData && !isLoading {
                                    loadMoreBeers()
                                }
                            }
                        }
                        
                        // ローディングインジケーター
                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(1.2)
                                Text(localizationService.loading)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding()
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .background(Color(.systemGroupedBackground))
                    .refreshable {
                        await refreshBeers()
                    }
                }
            }
            .background(BeerThemedBackgroundView())
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $selectedBeer) { beer in
            BeerDetailView(beer: beer)
                .environmentObject(firestoreService)
        }
        .onAppear {
            if beers.isEmpty {
                loadInitialBeers()
            }
        }
    }
    
    // MARK: - 初回データ読み込み
    private func loadInitialBeers() {
        isLoading = true
        firestoreService.resetPagination()
        
        firestoreService.observeBeers(sortDescending: sortDescending) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let newBeers):
                    self.beers = newBeers
                    self.hasMoreData = newBeers.count == 20 // pageSize
                case .failure(let error):
                    print("Error loading initial beers: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - 追加データ読み込み
    private func loadMoreBeers() {
        guard !isLoading && hasMoreData else { return }
        
        isLoading = true
        firestoreService.loadMoreBeers { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let newBeers):
                    if !newBeers.isEmpty {
                        self.beers.append(contentsOf: newBeers)
                        self.hasMoreData = newBeers.count == 20 // pageSize
                    } else {
                        self.hasMoreData = false
                    }
                case .failure(let error):
                    print("Error loading more beers: \(error.localizedDescription)")
                    self.hasMoreData = false
                }
            }
        }
    }
    
    // MARK: - リフレッシュ
    private func refreshBeers() async {
        await MainActor.run {
            self.beers.removeAll()
            self.hasMoreData = true
        }
        loadInitialBeers()
    }
    
    // MARK: - ソート順変更
    private func changeSortOrder(descending: Bool) {
        guard !isLoading else { return }
        
        isLoading = true
        // 既存のデータをクリアしてからソート順を変更
        beers.removeAll()
        hasMoreData = true
        
        firestoreService.changeSortOrder(descending: descending) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let newBeers):
                    self.beers = newBeers
                    self.hasMoreData = newBeers.count == 20 // pageSize
                case .failure(let error):
                    print("Error changing sort order: \(error.localizedDescription)")
                    // エラー時も状態をリセット
                    self.hasMoreData = true
                }
            }
        }
    }
}
