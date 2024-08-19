//
//  AddChannelVC.swift
//  Chat_UIKIt
//
//  Created by Arshif on 19/08/2024.
//

import UIKit
import StreamChat

class AddChannelVC: UIViewController {
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Channel Name"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let idTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Channel ID"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let pickerTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Select Channel Type"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var buttonSubmit: UIButton = {
        let button = UIButton()
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(tapActionButtonSubmit), for: .touchUpInside)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 4
        return button
    }()
    
    var selectedChannel: ChannelType? {
        didSet {
            pickerTextField.text = selectedChannel?.title
        }
    }
    
    private let pickerView: UIPickerView = UIPickerView()
    
    private var availableChannelTypes: [ChannelType]  = [.livestream, .messaging, .team, .gaming, .commerce]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        title = "ADD Channel"
        
        // Set delegates and data sources
        pickerView.delegate = self
        pickerView.dataSource = self
        
        pickerTextField.inputView = pickerView
        
        
        // Create and set toolbar for the picker view
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexSpace, doneButton], animated: true)
        
        pickerTextField.inputAccessoryView = toolbar
        
        pickerTextField.delegate = self
        
        // Add subviews
        view.addSubview(nameTextField)
        view.addSubview(idTextField)
        view.addSubview(pickerTextField)
        view.addSubview(buttonSubmit)
        
        // Set up constraints
        setupConstraints()
    }
    
    func createChannel() {
        
        guard let id = idTextField.text, let name = nameTextField.text, let selectedChannel else { return }
        
        do {
            let channelId = try ChannelId(cid: "\(selectedChannel.rawValue):\(id)")
            let channelController = try ChatClient.shared.channelController(createChannelWithId: channelId, name: name)
            channelController.synchronize { error in
            
                
                if error == nil {
                    self.dismiss(animated: true)
                } else {
                    // show error alert
                }
                
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
        
        idTextField.text = nil
        nameTextField.text = nil
        self.selectedChannel = nil
        
    }
    
    // MARK: - Actions
    @objc private func doneTapped() {
        pickerTextField.resignFirstResponder()
    }
    
    @objc private func tapActionButtonSubmit() {
        createChannel()
    }
    
    // MARK: - Layout
    private func setupConstraints() {
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        idTextField.translatesAutoresizingMaskIntoConstraints = false
        pickerTextField.translatesAutoresizingMaskIntoConstraints = false
        buttonSubmit.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Name TextField constraints
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // ID TextField constraints
            idTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            idTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            idTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            idTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // Picker TextField constraints
            pickerTextField.topAnchor.constraint(equalTo: idTextField.bottomAnchor, constant: 20),
            pickerTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            pickerTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            pickerTextField.heightAnchor.constraint(equalToConstant: 40),
            
            buttonSubmit.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonSubmit.topAnchor.constraint(equalTo: pickerTextField.bottomAnchor, constant: 40)
        ])
    }
}

// MARK: - UIPickerViewDelegate & UIPickerViewDataSource
extension AddChannelVC: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availableChannelTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return availableChannelTypes[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedChannel = availableChannelTypes[row]
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField != pickerTextField
    }
}
