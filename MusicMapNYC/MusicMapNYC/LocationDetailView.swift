import SwiftUI

struct LocationDetailView: View {
    let location: Location
    @EnvironmentObject var store: LocationStore

    @State private var authorName = ""
    @State private var reviewText = ""
    @State private var rating = 5

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(location.name)
                    .font(.title2.bold())

                Text(location.category.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.accentColor)

                Label(location.address, systemImage: "location")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Label(location.yearRange, systemImage: "calendar")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Divider()

                Text(location.description)
                    .font(.body)

                if location.artist != nil {
                    albumArtworkSection
                }

                Divider()

                reviewsSection
            }
            .padding()
        }
        .onAppear {
            store.loadArtworkIfNeeded(for: location)
        }
    }

    private var albumArtworkSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let url = store.artworkURLByLocationID[location.id] {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } placeholder: {
                    ProgressView()
                        .frame(height: 200)
                }
                Text("Artwork via Apple Music")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            } else {
                ProgressView("Looking up artwork…")
                    .frame(height: 100)
            }
        }
    }

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reviews")
                .font(.headline)

            let existingReviews = store.reviews(for: location.id)
            if existingReviews.isEmpty {
                Text("No reviews yet — be the first.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(existingReviews) { review in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(review.author.isEmpty ? "Anonymous" : review.author)
                                .font(.subheadline.bold())
                            Spacer()
                            starRow(for: review.rating, interactive: false)
                        }
                        Text(review.text)
                            .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }
            }

            Divider()

            Text("Add a review")
                .font(.subheadline.bold())

            TextField("Your name (optional)", text: $authorName)
                .textFieldStyle(.roundedBorder)

            starRow(for: rating, interactive: true) { newRating in
                rating = newRating
            }

            TextField("Share your experience…", text: $reviewText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)

            Button("Submit Review") {
                let review = Review(author: authorName, rating: rating, text: reviewText)
                store.addReview(review, for: location.id)
                authorName = ""
                reviewText = ""
                rating = 5
            }
            .buttonStyle(.borderedProminent)
            .disabled(reviewText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }

    // Renders 5 stars. When interactive, tapping a star calls onTap with the new rating.
    private func starRow(for rating: Int, interactive: Bool, onTap: ((Int) -> Void)? = nil) -> some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .foregroundStyle(.yellow)
                    .onTapGesture {
                        if interactive {
                            onTap?(star)
                        }
                    }
            }
        }
    }
}

#Preview {
    LocationDetailView(location: Location(
        id: "cbgb",
        name: "CBGB (original site)",
        category: .venue,
        address: "315 Bowery, New York, NY 10003",
        yearRange: "1973–2006",
        description: "Legendary punk club that launched the Ramones, Blondie, Patti Smith, and Talking Heads.",
        artist: nil,
        albumTitle: nil,
        coordinate: nil
    ))
    .environmentObject(LocationStore())
}
