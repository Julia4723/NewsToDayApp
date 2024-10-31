//
//  Article.swift
//  NewsToDayApp
//
//  Created by Сергей Сухарев on 23.10.2024.
//

import UIKit
import Kingfisher

final class ArticleViewController: UIViewController {
    
    var article: Article
    var favoriteManager = FavoriteManager.shared
    
    var liked: Bool = false
    
    let imageView = UIImageView()
    let labelTitle = UILabel()
    let labelDescription = UILabel()
    let labelAuthor = UILabel()
    let textView = UITextView()
    let buttonBack = UIButton()
    let buttonBookmark = UIButton()
    let buttonShared = UIButton()
    
    init(article: Article) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(article)
        setupNavBar()
        setupView()
        setupConstraints()
        configuration()
        setupLikedState()
    }
 
    private func setupView() {
        view.addSubview(imageView)
        view.addSubview(buttonShared)
        view.addSubview(labelTitle)
        view.addSubview(labelDescription)
        view.addSubview(labelAuthor)
        view.addSubview(textView)
    }
    
    private func setupNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: buttonBack)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buttonBookmark)
    }
    private func configuration() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        setupImage()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        buttonBack.setImage(UIImage.backButtonNavBar, for: .normal)
        buttonBack.addTarget(self, action: #selector (backButtonTapped), for: .touchUpInside)
        
        buttonBookmark.setImage(UIImage.bookmarkNavBar, for: .normal)
        buttonBookmark.addTarget(self, action: #selector (bookmarkTapped), for: .touchUpInside)
        
        buttonShared.setImage(UIImage.share, for: .normal)
        buttonShared.addTarget(self, action: #selector (sharedTapped), for: .touchUpInside)
        buttonShared.translatesAutoresizingMaskIntoConstraints = false
        
        labelTitle.font = .systemFont(ofSize: 12, weight: .semibold)
        labelTitle.textColor = .white
        labelTitle.backgroundColor = .brandPurplePrimary
        labelTitle.layer.cornerRadius = 16
        labelTitle.sizeToFit()
        labelTitle.clipsToBounds = true
        labelTitle.text = ("  \(article.source.name)  ")
        labelTitle.translatesAutoresizingMaskIntoConstraints = false
        
        labelDescription.font = .systemFont(ofSize: 20, weight: .bold)
        labelDescription.textColor = .white
        labelDescription.textAlignment = .left
        labelDescription.numberOfLines = 4
        labelDescription.clipsToBounds = true
        labelDescription.sizeToFit()
        labelDescription.text = article.description
        labelDescription.translatesAutoresizingMaskIntoConstraints = false
        
        labelAuthor.textColor = .white
        labelAuthor.numberOfLines = 0
        labelAuthor.sizeToFit()
        labelAuthor.textAlignment = .left
        labelAuthor.clipsToBounds = true
        let nameAuthor = article.author ?? "No Author"
        let autor = "Author"
        let attributes1 = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .semibold)
                ]
        let attributedText1 = NSMutableAttributedString(string: nameAuthor, attributes: attributes1)

        let attributes2 = [
            NSAttributedString.Key.foregroundColor: UIColor.gray,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular)
                ]
        let attributedText2 = NSMutableAttributedString(string: autor, attributes: attributes2)

        let combinedAttributedString = NSMutableAttributedString()
                combinedAttributedString.append(attributedText1)
                combinedAttributedString.append(NSAttributedString(string: "\n"))
                combinedAttributedString.append(attributedText2)

        labelAuthor.attributedText = combinedAttributedString
        labelAuthor.translatesAutoresizingMaskIntoConstraints = false
        
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 16, weight: .regular)
        textView.textColor = .black
        textView.textContainerInset = UIEdgeInsets( top: 20, left: 20, bottom: 0, right: 20)
        textView.setContentHuggingPriority(.required, for: .vertical)
        textView.textAlignment = .justified
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = article.content ?? "No content"
    }
    
    private func setupLikedState() {
        liked = favoriteManager.isFavorite(article: article)
        let bookmarkImage = liked ? UIImage(resource: .bookmarkFill) : UIImage(resource: .bookmarkOutline)
        buttonBookmark.setImage(bookmarkImage, for: .normal)
    }
    
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    @objc private func sharedTapped() {
        print("sharedTapped")
        
    }
    
    @objc private func bookmarkTapped() {
        if liked {
            favoriteManager.removeFromFavorites(article: article)
            liked = false
            buttonBookmark.setImage(.bookmarkFill, for: .normal)
        } else {
            favoriteManager.addToFavorites(article: article)
            liked = true
            buttonBookmark.setImage(.bookmarkOutline, for: .normal)
        }
    }
    
    func setupImage() {
        let imageURL = URL(string: article.urlToImage ?? "")
        imageView.kf.indicatorType = .activity
        let placeholderImage = UIImage(named: "image")
        imageView.kf.setImage(
            with: imageURL,
            options: [
                KingfisherOptionsInfoItem
                    .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ]) { result in
                switch result {
                case .success(let value):
                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                case .failure(let error):
                    print("Job failed: \(error.localizedDescription)")
                    self.imageView.image = placeholderImage
                }
            }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/2.2),

            buttonShared.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            buttonShared.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            labelTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            labelTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            labelTitle.heightAnchor.constraint(equalToConstant: 32),
            
            labelDescription.bottomAnchor.constraint(equalTo: labelAuthor.topAnchor, constant: -16),
            labelDescription.topAnchor.constraint(equalTo: labelTitle.bottomAnchor, constant: 16),
            labelDescription.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            labelDescription.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            labelAuthor.topAnchor.constraint(equalTo: labelDescription.bottomAnchor, constant: -24),
            labelAuthor.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -16),
            labelAuthor.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            labelAuthor.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
        ])
    }
    
}


@available(iOS 18.0, *)
#Preview { UINavigationController(rootViewController: ArticleViewController(article: .init(source: .init(id: "", name: ""), author: "World", title: "Hello", description: "adsd,/nfkelwnfjnbwejknfjkn dksalkfnaklsndfklnsadklnfkansaskf/n dklnsadklnfklds\n\nanlkfnklasdnf", url: "", urlToImage: "", publishedAt: "", content: "dsfsdfssfd ajknsjdfnklsndlf\nlsdflknl\nksddsfksdfak\nsdfsda\nfsdafasfsadfsaf\nsdfsdfasdfsadfsdfdwsf\nfsdfsafsadfdfdsn\n\n\\nasdak\n\nsdnaklf\n\n\n\n\n\nnkjdsnjkfnkjsanfjknsdjkbfjkbhwjqevfuyvwessdada\n\n\nsmfnmsakd mds f sm fm sdfs mf, dm fma ,m sdmf s ,f ,m\ns dfm sm df,\nm sdm fm sdm f,ms df sd, fm sdm, f")))}
