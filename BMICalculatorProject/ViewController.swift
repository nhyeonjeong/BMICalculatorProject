//
//  ViewController.swift
//  BMICalculatorProject
//
//  Created by 남현정 on 2024/01/04.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    // 버튼 아웃렛
    @IBOutlet weak var resultButton: UIButton!
    @IBOutlet weak var randomBmiButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    // textfield 아웃렛
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    let userdefault = UserDefaults.standard
    
    var height: Double = 0
    var weight: Double = 0
    
    // 유저디폴트 key값과 UITextField를 매치해서 저장하기
    var textFieldDictionary: [String: UITextField] = [:]
    
    var tempValue = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttonList: [UIButton] = [resultButton, randomBmiButton, resetButton]
        
        textFieldDictionary = ["myHeight": heightTextField,
                               "myWeight": weightTextField,
                               "nickname": nicknameTextField]
    
        // Label의 너비 안정해주니까 imageView사이간격넣을떄 ...라고 Label에 떠서 정해줌ㅎ
        
        // 이미지 디자인
        // 이미지ratio를 준 뒤 assets 사진의 너비높이 비율을 확인해서 그대로 적용..
        imageView.image = .image
        imageView.contentMode = .scaleAspectFit
        
        // 버튼 디자인
        for item in buttonList {
            designButton(item)
        }
        
//        UserDefaults.standard.string(forKey: "nickname")

        // textField디자인
        for (_, textfield) in textFieldDictionary {
            designTextField(textfield)
        }
        
        // 값가져와서 textfield에 띄우기(닉네임, 키, 몸무게)
        assignTextFieldFromUserdefault(textFieldDictionary)
        
        // 닉네임라벨에 텍스트 띄우기
        assignLabelFromUserdefault(nicknameLabel)
    
    }
    /// reset버튼 눌렀을 때 닉네임은 "", 키와 몸무게는 nil로 유저티폴트에 저장
    /// reset된 값 토대로 label, textfield에 띄우기
    @IBAction func resetButtonClicked(_ sender: UIButton) {
        // 유저디폴트 업데이트
        saveValueToUserDefault(nickname: "", height: 0.0, weight: 0.0)
        
        assignTextFieldFromUserdefault(textFieldDictionary)
        assignLabelFromUserdefault(nicknameLabel)
    }
    
    /// 랜덤 숫자 추천
    @IBAction func randomButtonClicked(_ sender: UIButton) {
        heightTextField.text = "\(Int.random(in: 1...250))"
        weightTextField.text = "\(Int.random(in: 1...250))"
    }
    /*
    // 뒤에 cm, kg 붙어서 나오도록
    // Editing Changed
    @IBAction func textFieldValueChanged(_ sender: UITextField) {
        print("f")
        tempValue = sender.text!
        if sender == heightTextField {
            heightTextField.text = tempValue + "cm"
        } else if sender == weightTextField {
            weightTextField.text = tempValue + "kg"
        }
    }
     */
    
    /// 결과확인 눌렀을 때 textfield 문자 확인
    @IBAction func resultButtonClicked(_ sender: UIButton) {
        // textfield에서 가져온 텍스트
        let heightString = heightTextField.text!
        let weightString = weightTextField.text!
        
        var checkheight: Bool = false
        var checkweight: Bool = false
        /*
         // 이렇게 해면 weightTextField의 placeholder는 못써줌
        guard let height = Int(height) else {
            heightTextField.placeholder = "숫자를 입력해주세요"
            return
        }
        guard let weight = Int(weight) else {
            weightTextField.placeholder = "숫자를 입력해주세요"
            return
        }
         */
        
        // 1. 빈칸이거나 아무것도 안 적었을 때 확인 -> 공백일떄도 "숫자를 입력해주세요"로..
        
        // 2. 문자를 입력했을 때나 비현실적인 숫자일때
        // checkValid뒤에 비현실적인 숫자인지 체크했는데
        // 그렇게 되면 하나의 textfield에서 숫자가 아니라 오류가 났다면 다른 textfield까지 비현실적인 숫자인지 체크할 수 없기 떼문에
        // checkValid앞으로 땡겼다.
        checkheight = checkTextField(heightTextField, text: heightString)
        checkweight = checkTextField(weightTextField, text: weightString)
        
        // 어느 하나라도 false 라면 return -> false면 알람 실행되지 않는다.
        if !checkValid(checkheight: checkheight, checkweight: checkweight) { return }
        /*
        // 범위가 이상할 떄 -> checkValid앞으로 땡겨줌
        if height < 0 || height > 250 {
            heightTextField.text = ""
            heightTextField.placeholder = "비현실적인 키입니다"
            checkheight = false
        } else {
            checkheight = true
        }
        if weight < 1 || weight > 250 {
            weightTextField.text = ""
            weightTextField.placeholder = "비현실적인 몸무게입니다"
            checkweight = false
            
        } else {
            checkweight = true
        }
         */
        
        // 여기까지 통과했으면 알람실행 및 유저디폴트 저장
        // nickname은 입력안해도 괜찮^^
        saveValueToUserDefault(nickname: nicknameTextField.text!, height: height, weight: weight)
        showAlert()
        
    }
    
    /// resultButtonClicked에서 checkheight,weight 둘 다 true일 때 알람
    func showAlert() {
        // placeholder다시 초기화
        heightTextField.placeholder = ""
        weightTextField.placeholder = ""
        
        assignLabelFromUserdefault(nicknameLabel)
        assignTextFieldFromUserdefault(textFieldDictionary)
        
        let bmiResult: String = calculateBMI() // bmi결과 저장
        
        // alert
        let alert = UIAlertController(title: "BMI결과", message: "당신은 \(bmiResult)입니다", preferredStyle: .alert)
        let button1 = UIAlertAction(title: "ok", style: .default)
        alert.addAction(button1)
        present(alert, animated: true)
        
    }
    
    /// 둘 다 유효한 숫자인지 확인
    func checkValid(checkheight: Bool, checkweight: Bool) -> Bool {
        if checkheight && checkweight {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func viewClicked(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)

    }
    // 리턴키 눌렀을 때 키보드 내려가도록
    @IBAction func returnKeyClicked(_ sender: Any) {
        view.endEditing(true)
    }
    /// 키와 몸무게가 숫자인지, 현실적인 숫자인지 확인하는 함수
    func checkTextField(_ textField: UITextField, text: String) -> Bool {
        var isValid = false
        
        if let valueInt = Double(text) {
            
            if valueInt < 1 || valueInt > 250 {
                textField.text = ""
                textField.placeholder = "비현실적인 \(textField == heightTextField ? "키" : "몸무게")입니다"
                isValid = false
            } else {
                if textField == heightTextField {
                    height = valueInt
                } else {
                    weight = valueInt
                }
                isValid = true
            }
        } else {
            textField.text = ""
            textField.placeholder = "숫자를 입력해주세요"
            isValid = false
        }
        return isValid
    }
    
    /// bmi계산
    func calculateBMI() -> String {
        let bmi = weight / ((height * 0.01) * (height * 0.01)) // Double타입
        
        switch bmi {
        case ..<0: return "오류"
        case 0..<18.5: return "저체중"
        case 18.5..<25: return "표준"
        case 25..<30: return "과체중"
        case 30..<35: return "비만"
        case 35..<100: return "고도비만"
        default: return "초고도비만"
    
        }
    }
    
    /// 키로 유저디폴트에서 값을 가져와 인자로 받아온 label에 띄워주기
    func assignLabelFromUserdefault(_ label: UILabel) {
        // nickname이 textfield에 입력되었기 때문에 아무것도 입력하지 않아도 ""으로 저장되었을 것이다.
        let nickname = userdefault.string(forKey: "nickname")!
        
        if nickname == "" {
            nicknameLabel.text = "당신의 BMI지수를\n알려드릴게요."
        } else {
            nicknameLabel.text = "\(nickname)님의 BMI지수를\n알려드릴게요."
        }
    }
    /// 키로 유저디폴트에서 값을 가져와 인자로 받아온 닉네임, 몸무게, 키textifeld에 띄워주기
    func assignTextFieldFromUserdefault(_ textFieldDictionary: [String: UITextField]) {
        // nicknameTextField라면 값이 String?타입이므로 옵셔널바인딩을 해줘야한다.
        for (key, textField) in textFieldDictionary {
            if textField == nicknameTextField {
                if let value = userdefault.string(forKey: key) {
                    textField.text = value
                } else {
                    textField.text = nil
                }
            } else {
                textField.text = "\(userdefault.double(forKey: key))"
            }
        }
    }
    
    /// 키로 유저디폴트에 저장하기
    func saveValueToUserDefault(nickname: String, height: Double, weight: Double) {
        userdefault.set(nickname, forKey: "nickname")
        userdefault.set(height, forKey: "myHeight")
        userdefault.set(weight, forKey: "myWeight")

    }
    
    /// textfield디자인
    func designTextField(_ textField: UITextField) {
        textField.layer.cornerRadius = 15
        textField.layer.borderColor = UIColor.systemIndigo.cgColor
        textField.layer.borderWidth = 2
        // 키보드타입은 숫자와 . 나올 수 있도록
        if textField != nicknameTextField {
            textField.keyboardType = .numbersAndPunctuation
        }
    }
    /// 버튼 디자인
    func designButton(_ button: UIButton) {
        if button == randomBmiButton {
            button.layer.borderColor = UIColor.systemBackground.cgColor
        } else {
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor.systemIndigo.cgColor
            if button == resetButton {
                button.layer.cornerRadius = 30
            } else {
                button.layer.cornerRadius = 10
            }
        }
    }
}

