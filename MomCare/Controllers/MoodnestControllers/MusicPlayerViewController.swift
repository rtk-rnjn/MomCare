//
//  MusicPlayerViewController.swift
//  MomCare
//
//  Created by RITIK RANJAN on 28/02/25.
//

import UIKit

@MainActor
protocol MusicPlayerDelegate: AnyObject {
    func playPauseButtonTapped(_ sender: Any?)
    func forwardButtonTapped(_ sender: Any?)
    func backwardButtonTapped(_ sender: Any?)

    func durationSliderValueChanged(value: Float)
    func durationSliderTapped(_ gesture: UITapGestureRecognizer)

    func volumeSliderValueChanged(value: Float)
    func volumeButtonTapped(_ sender: UIButton)
}

class MusicPlayerViewController: UIViewController {

    // MARK: Internal

    var delegate: MusicPlayerDelegate?
    var song: Song?

    lazy var songSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0.0
        slider.minimumTrackTintColor = .white
        slider.thumbTintColor = .clear
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.setContentHuggingPriority(.required, for: .horizontal)
        slider.setContentHuggingPriority(.required, for: .vertical)
        slider.setContentCompressionResistancePriority(.required, for: .horizontal)
        slider.setContentCompressionResistancePriority(.required, for: .vertical)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(durationSliderTapped))
        slider.addGestureRecognizer(tapGesture)

        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)

        return slider
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }

    @objc func durationSliderTapped(_ gesture: UITapGestureRecognizer) {
        delegate?.durationSliderTapped(gesture)
    }

    // MARK: Private

    private lazy var albumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        Task {
            let image = await song?.image ?? UIImage(systemName: "music.note")
            DispatchQueue.main.async {
                imageView.image = image
            }
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let _249Priority = UILayoutPriority(249)

        imageView.setContentHuggingPriority(_249Priority, for: .horizontal)
        imageView.setContentHuggingPriority(_249Priority, for: .vertical)
        imageView.setContentCompressionResistancePriority(_249Priority, for: .horizontal)
        imageView.setContentCompressionResistancePriority(_249Priority, for: .vertical)

        return imageView
    }()

    private lazy var songLabel: UILabel = {
        let label = UILabel()
        label.text = song?.metadata?.title
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    private lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.text = song?.metadata?.artist
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    lazy var startDurationLabel: UILabel = {
        let label = UILabel()
        label.text = "-:--"
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    lazy var endDurationLabel: UILabel = {
        let label = UILabel()
        label.text = "--:--"
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    private lazy var backwardButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .largeTitle))
        button.setImage(UIImage(systemName: "backward.fill", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.contentHorizontalAlignment = .trailing
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .vertical)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .vertical)

        button.addTarget(self, action: #selector(backwardTapped), for: .touchUpInside)

        return button
    }()

    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .largeTitle))
        button.setImage(UIImage(systemName: "play.fill", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.contentHorizontalAlignment = .center
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .vertical)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .vertical)

        button.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)

        return button
    }()

    private lazy var forwardButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .largeTitle))
        button.setImage(UIImage(systemName: "forward.fill", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.contentHorizontalAlignment = .leading
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .vertical)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .vertical)

        button.addTarget(self, action: #selector(forwardTapped), for: .touchUpInside)

        return button
    }()

    private lazy var speakerLowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "speaker.fill"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .vertical)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .vertical)
        return button
    }()

    private lazy var volumeSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0.5
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.minimumTrackTintColor = .white
        slider.translatesAutoresizingMaskIntoConstraints = false

        let _999Priority = UILayoutPriority(999)

        slider.setContentHuggingPriority(_999Priority, for: .horizontal)
        slider.setContentHuggingPriority(_999Priority, for: .vertical)
        slider.setContentCompressionResistancePriority(_999Priority, for: .horizontal)
        slider.setContentCompressionResistancePriority(_999Priority, for: .vertical)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(volumeButtonTapped))
        slider.addGestureRecognizer(tapGesture)

        slider.addTarget(self, action: #selector(volumeSliderValueChanged), for: .valueChanged)

        return slider
    }()

    private lazy var speakerHighButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .vertical)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .vertical)
        return button
    }()

    // MARK: - Stack Views
    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [songLabel, artistLabel])
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var durationLabelsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [startDurationLabel, endDurationLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var sliderStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [songSlider, durationLabelsStackView])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var playerInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleStackView, sliderStackView])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var controlButtonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [backwardButton, playButton, forwardButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var volumeControlStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [speakerLowButton, volumeSlider, speakerHighButton])
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var controlsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [playerInfoStackView, controlButtonsStackView, volumeControlStackView])
        stackView.axis = .vertical
        stackView.spacing = 35
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [albumImageView, controlsStackView])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private func prepareUI() {
        let color = /*song?.image?.dominantColor() ??*/ UIColor.systemGray5
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds

        let lighterColor = color.withAlphaComponent(0.8).cgColor
        let middleColor = color.withAlphaComponent(1.0).cgColor
        let darkerColor = UIColor.black.withAlphaComponent(0.9).cgColor

        gradientLayer.colors = [lighterColor, middleColor, darkerColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

        view.layer.insertSublayer(gradientLayer, at: 0)

        view.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }

    @objc private func sliderValueChanged(_ sender: UISlider) {
        delegate?.durationSliderValueChanged(value: sender.value)
    }

    @objc private func playPauseTapped(sender: UIButton) {
        delegate?.playPauseButtonTapped(sender)
    }

    @objc private func forwardTapped(sender: UIButton) {
        delegate?.forwardButtonTapped(sender)
    }

    @objc private func backwardTapped(sender: UIButton) {
        delegate?.backwardButtonTapped(sender)
    }

    @objc private func volumeSliderValueChanged(_ sender: UISlider) {
        delegate?.volumeSliderValueChanged(value: sender.value)
    }

    @objc private func volumeButtonTapped(_ sender: UIButton) {
        delegate?.volumeButtonTapped(sender)
    }
}
