
//
//  BeerRecordsList.swift
//  beer_analyzer
//

import SwiftUI

struct BeerRecordsList: View {
    @EnvironmentObject var firestoreService: FirestoreService
    
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
                        Text(NSLocalizedString("beer_records", comment: ""))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                        Text(String(format: NSLocalizedString("records_count", comment: ""), beers.count))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // ソートコントロール
                    HStack {
                        Text(NSLocalizedString("sort_order", comment: ""))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Picker(NSLocalizedString("sort_order", comment: ""), selection: $sortDescending) {
                            Text(NSLocalizedString("sort_newest", comment: "")).tag(true)
                            Text(NSLocalizedString("sort_oldest", comment: "")).tag(false)
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
                        Text(NSLocalizedString("no_records", comment: ""))
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text(NSLocalizedString("start_analyzing", comment: ""))
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    // ビールリスト - グリッドレイアウト
                    GeometryReader { geometry in
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 16) {
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
                                .onAppear {
                                    // 無限スクロールのトリガー
                                    if beer.id == beers.last?.id && hasMoreData && !isLoading {
                                        loadMoreBeers()
                                    }
                                }
                            }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            
                            // ローディングインジケーター
                            if isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(1.2)
                                    Text(NSLocalizedString("loading", comment: ""))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding()
                            }
                        }
                    }
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
