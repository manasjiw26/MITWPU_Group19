import UIKit

class Help_SupportViewController: UIViewController {

    @IBOutlet weak var textCard: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var emailCard: UIView!
    @IBOutlet weak var emailLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Help & Support"
        view.backgroundColor = .systemGroupedBackground

        styleCards()
        setupHelpText()
        setupEmail()
    }
}
extension Help_SupportViewController {

    func styleCards() {
        [textCard, emailCard].forEach { card in
            card?.backgroundColor = .white
            card?.layer.cornerRadius = 16
            card?.layer.shadowColor = UIColor.black.cgColor
            card?.layer.shadowOpacity = 0.04
            card?.layer.shadowRadius = 8
            card?.layer.shadowOffset = CGSize(width: 0, height: 4)
        }
    }
}
extension Help_SupportViewController {

    func setupHelpText() {
        textLabel.attributedText = styledHelpText()
        textLabel.numberOfLines = 0
    }

    func styledHelpText() -> NSAttributedString {

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.paragraphSpacing = 2

        let fullText = NSMutableAttributedString()

        func body(_ text: String) {
            fullText.append(NSAttributedString(string: text, attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.label,
                .paragraphStyle: paragraphStyle
            ]))
        }

        func title(_ text: String) {
            fullText.append(NSAttributedString(string: text, attributes: [
                .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                .foregroundColor: UIColor.label,
                .paragraphStyle: paragraphStyle
            ]))
        }

        body("We’re here to help you have the best experience with App Name.\n")
        
        body("If you’re facing issues, have questions, or need assistance using features like Vibe tracking, Explore activities, Special Dates, or the Memory Jar, our support team is happy to help.\n\n")

        title("Common Support Topics\n")
        body("• Adding or editing special dates\n• Managing your Memory Jar entries\n• Account and profile settings\n• Notifications and reminders\n• App performance or technical issues\n\n")

        title("Contact Support\n")
        body("Need more help? Reach out to us and we’ll get back to you as soon as possible.")

        return fullText
    }
}
extension Help_SupportViewController {

    func setupEmail() {
        emailLabel.text = "help@yourapp.com"
        emailLabel.font = .systemFont(ofSize: 14, weight: .medium)
        emailLabel.textColor = .systemBlue

        let tap = UITapGestureRecognizer(target: self, action: #selector(openMail))
        emailCard.addGestureRecognizer(tap)
        emailCard.isUserInteractionEnabled = true
    }

    @objc func openMail() {
        if let url = URL(string: "mailto:help@yourapp.com") {
            UIApplication.shared.open(url)
        }
    }
}

