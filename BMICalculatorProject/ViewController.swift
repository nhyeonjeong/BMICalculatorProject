//
//  ViewController.swift
//  BMICalculatorProject
//
//  Created by 남현정 on 2024/01/04.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var resultButton: UIButton!
    @IBOutlet weak var randomBmiButton: UIButton!
    
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    
    var height: Double = 0
    var weight: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Label의 너비 안정해주니까 imageView사이간격넣을떄 ...라고 떠서 정해줌
        
        // 이미지 디자인
        // 이미지ratio를 준 뒤 assets 사진의 너비높이 비율을 확인해서 그대로 적용..
        imageView.image = .image
        imageView.contentMode = .scaleAspectFit
        // 결과확인버튼 Radius
        resultButton.layer.cornerRadius = 10
        // 랜덤버튼 border색
        randomBmiButton.layer.borderColor = UIColor.systemBackground.cgColor // 다크모드도 대응하도록?
        
        // textField디자인
        let textFieldList: [UITextField] = [heightTextField, weightTextField]
        
        for item in textFieldList {
            designTextField(item)
        }
    }
    /// 랜덤 숫자 추천
    @IBAction func randomButtonClicked(_ sender: UIButton) {
        heightTextField.text = "\(Int.random(in: 1...250))"
        weightTextField.text = "\(Int.random(in: 1...250))"
    }
    /// 결과확인 눌렀을 때 textfield 문자 확인
    @IBAction func resultButtonClicked(_ sender: UIButton) {
        // textfield에서 가져온 텍스트
        let optionalHeight = heightTextField.text!
        let optionalWeight = weightTextField.text!
        
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
        
        // 빈칸이거나 아무것도 안 적었을 때 확인 -> 공백일떄도 "숫자를 입력해주세요"로..
        
        // 문자를 입력했을 때나 비현실적인 숫자일때
        // checkValid뒤에 비현실적인 숫자인지 체크했는데 
        // 그렇게 되면 하나의 textfield에서 숫자가 아니라 오류가 났다면 다른 textfield까지 비현실적인 숫자인지 체크할 수 없기 떼문에
        // checkValid앞으로 땡겼다.
        if let heightInt = Double(optionalHeight) {
            height = heightInt
            checkheight = true
        } else {
            heightTextField.text = ""
            heightTextField.placeholder = "숫자를 입력해주세요"
            checkheight = false
        }
        if checkheight {
            if height < 0 || height > 250 {
                heightTextField.text = ""
                heightTextField.placeholder = "비현실적인 키입니다"
                checkheight = false
            } else {
                checkheight = true
            }
        }
        
        if let weightInt = Double(optionalWeight) {
            weight = weightInt
            checkweight = true
        } else {
            weightTextField.text = ""
            weightTextField.placeholder = "숫자를 입력해주세요"
            checkweight = false
        }
        
        if checkweight {
            if weight < 1 || weight > 250 {
                weightTextField.text = ""
                weightTextField.placeholder = "비현실적인 몸무게입니다"
                checkweight = false
                
            } else {
                checkweight = true
            }
            
        }
        
        // 어느 하나라도 이상하다면 return
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
        
        if !checkValid(checkheight: checkheight, checkweight: checkweight) { return }
        
        // 여기까지 통과했으면 알람실행
        showAlert()
        
    }
    
    /// resultButtonClicked에서 checkheight,weight 둘 다 true일 때 알람
    func showAlert() {
        // placeholder다시 초기화
        heightTextField.text = ""
        weightTextField.text = ""
        
        let bmiResult = calculateBMI() // bmi결과 저장
        
        let alert = UIAlertController(title: "BMI결과", message: "당신은 \(bmiResult)입니다", preferredStyle: .alert)
        
        let button1 = UIAlertAction(title: "ok", style: .default)
        
        alert.addAction(button1)
        
        present(alert, animated: true)
        
    }
    /// 둘 다 유효한 숫자인지 확인
    func checkValid(checkheight: Bool, checkweight: Bool) -> Bool {
        if checkheight == true && checkweight == true {
            return true
        } else {
            return false
        }
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
    
    @IBAction func viewClicked(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)

    }
    // 리턴키 눌렀을 때 키보드 내려가도록
    @IBAction func returnKeyClicked(_ sender: Any) {
        view.endEditing(true)
    }
    
    /*
     // 끝에 cm, kg를 붙여주려면?
    @IBAction func textFieldValueChanged(_ sender: UITextField) {
        if sender == heightTextField {
            heightTextField.text! += "cm"
        } else if sender == weightTextField {
            weightTextField.text! += "Kg"
        }
    }
     */
    
    
    func designTextField(_ textField: UITextField) {
        textField.layer.cornerRadius = 15
        textField.layer.borderColor = UIColor.systemIndigo.cgColor
        textField.layer.borderWidth = 2
        // 키보드타입은 숫자와 . 나올 수 있도록
        textField.keyboardType = .numbersAndPunctuation
    
    }
}

