import SwiftUI

struct MainView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        VStack {
            Spacer()

            switch selectedTab {
            case .home:
                Text("Welcome to home!")
                    .font(.largeTitle)
                    .bold()
                    .padding()

            case .cat:
                CatListView()
            }

            Spacer()

            HStack {
                Spacer()

                Button(action: {
                    selectedTab = .home
                }) {
                    VStack {
                        Image(systemName: "house.fill")
                            .font(.system(size: 24))
                        Text("Home")
                            .font(.caption)
                    }
                }
                .foregroundColor(selectedTab == .home ? .blue : .gray)

                Spacer()

                Button(action: {
                    selectedTab = .cat
                }) {
                    VStack {
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 24))
                        Text("Cat")
                            .font(.caption)
                    }
                }
                .foregroundColor(selectedTab == .cat ? .blue : .gray)

                Spacer()
            }
            .padding()
            .background(Color.white.shadow(radius: 5))
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

enum Tab {
    case home
    case cat
}

struct Cat: Identifiable, Decodable {
    let id: String
    let name: String
    let reference_image_id: String?
    let description: String
    let temperament: String
    let origin: String
    let life_span: String
    
    var imageURL: URL? {
        guard let imageId = reference_image_id else { return nil }
        return URL(string: "https://cdn2.thecatapi.com/images/\(imageId).jpg")
    }
}

struct CatListView: View {
    @State private var cats: [Cat] = []
    @State private var selectedCat: Cat? = nil
    
    var body: some View {
        NavigationView {
            List(cats) { cat in
                HStack {
                    AsyncImage(url: cat.imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())

                    Text(cat.name)
                        .font(.headline)
                }
                .onTapGesture {
                    selectedCat = cat
                }
            }
            .navigationTitle("Cats")
            .onAppear(perform: fetchCats)
            .sheet(item: $selectedCat) { cat in
                CatDetailView(cat: cat)
            }
        }
    }

    func fetchCats() {
        guard let url = URL(string: "https://api.thecatapi.com/v1/breeds") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let cats = try JSONDecoder().decode([Cat].self, from: data)
                    DispatchQueue.main.async {
                        self.cats = cats
                    }
                } catch {
                    print("Failed to decode JSON: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}

struct CatDetailView: View {
    let cat: Cat

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let imageURL = cat.imageURL {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Color.gray
                    }
                    .frame(maxWidth: .infinity)
                }

                Text(cat.name)
                    .font(.largeTitle)
                    .bold()

                Text("Description: \(cat.description)")
                    .font(.body)

                Text("Temperament: \(cat.temperament)")
                    .font(.body)

                Text("Origin: \(cat.origin)")
                    .font(.body)

                Text("Life Span: \(cat.life_span) years")
                    .font(.body)

                Spacer()
            }
            .padding()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
