//
//  CloudSettingTableViewCell.swift
//  MGCloud
//
//  Created by sugc on 2023/12/6.
//

import Foundation

enum CloudSettingTableViewCellState {
    case empty
    case editingOrContent
}

class CloudSettingTableViewCell : UITableViewCell, UITextFieldDelegate {
    
    var boraderLayer : CALayer!
    var textFiled : UITextField!
    var placeHorlderLabel : UILabel!
    var rightBtn : UIButton!
    
    var rightBtnActionBlock : ((_ cell:CloudSettingTableViewCell)->Void)?
    var callBack : ((_ value:String?)->Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        boraderLayer.frame = CGRect(x: 20,
                                    y: 20,
                                    width: self.contentView.width - 40,
                                    height: self.contentView.height - 40)
        textFiled.frame = CGRect(x: 30,
                                 y: 20,
                                 width: self.contentView.width - 50,
                                 height: self.boraderLayer.frame.height)
        let trans = placeHorlderLabel.transform
        placeHorlderLabel.transform = .identity
        placeHorlderLabel.centerY = textFiled.centerY
        placeHorlderLabel.left = textFiled.left
        transFormPlaceHoder(shouldTrans: !trans.isIdentity)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func commonInit() {
        selectionStyle = .none
        boraderLayer = CALayer.init()
        boraderLayer.cornerRadius = 5.0
        boraderLayer.borderColor = UIColor.black.cgColor
        boraderLayer.borderWidth = 0.5
        boraderLayer.frame = contentView.bounds
        self.contentView.layer.addSublayer(boraderLayer)
        
        textFiled = UITextField.init(frame: self.contentView.bounds)
        textFiled.font = UIFont.systemFont(ofSize: 18)
        textFiled.backgroundColor = .clear
        textFiled.delegate = self
        textFiled.returnKeyType = .done
        textFiled.addTarget(self, action: #selector(textFiledValueChanged(textFiled:)), for: .valueChanged)
        textFiled.addTarget(self, action: #selector(textFiledValueChanged(textFiled: )), for: .editingChanged)
        
        placeHorlderLabel = UILabel.init(frame: .zero)
        placeHorlderLabel.font = UIFont.systemFont(ofSize: 18)
        placeHorlderLabel.backgroundColor = .white
        
        contentView.addSubview(textFiled)
        contentView.addSubview(placeHorlderLabel)
        rightBtn = UIButton.init(frame: .zero)
        rightBtn.addTarget(self, action: #selector(clickRightBtn), for: .touchUpInside)
    }
    
    //刷新界面
    func refresh(placeHoder:String, content:String, canEdit:Bool, callBack: ((_ value:String?)->Void)?,  rightIcon:UIImage?, actionBlock:((_ cell:CloudSettingTableViewCell)->Void)?) {
        
        //
        var shouldTrans = true
        if self.placeHorlderLabel.transform.isIdentity {
            shouldTrans = false
        }
        
        self.textFiled.isEnabled = canEdit
        self.placeHorlderLabel.transform = .identity
        self.placeHorlderLabel.text = placeHoder
        self.placeHorlderLabel.sizeToFit()
    
        self.transFormPlaceHoder(shouldTrans: shouldTrans)
        
        self.callBack = callBack
        self.rightBtnActionBlock = actionBlock
        self.textFiled.text = content
        
        rightBtn.setImage(rightIcon, for: .normal)
        rightBtn.isHidden = (rightIcon == nil)
        
        var state = CloudSettingTableViewCellState.empty
        if !content.isEmpty || self.textFiled.isEditing {
            state = .editingOrContent
        }
        changeToStateAnimate(state: state)
    }
    
    func changeToStateAnimate(state:CloudSettingTableViewCellState) {
        
        var borderColor = UIColor.black
        var borderWidth = 0.5
        var shouldTrans = false
        if (state == .editingOrContent) {
            borderColor = .blue
            borderWidth = 1.0
            shouldTrans = true
        }
        
        //
        UIView.animate(withDuration: 0.3) {
            self.boraderLayer.borderWidth = borderWidth
            self.boraderLayer.borderColor = borderColor.cgColor
            self.transFormPlaceHoder(shouldTrans: shouldTrans)
        }
    }
    
    //
    func transFormPlaceHoder(shouldTrans:Bool) {
        
        self.placeHorlderLabel.transform = .identity
        if !shouldTrans {
            return
        }

        let oriPosition = self.placeHorlderLabel.origin
        let oriSize = self.placeHorlderLabel.size
        let targetHeight = 15.0
        let scale = targetHeight / self.placeHorlderLabel.height
        
        //缩放后的位置
        let transPostion = CGPointMake(oriPosition.x + oriSize.width * (1 - scale) / 2.0,
                                       oriPosition.y + (oriSize.height - targetHeight)  / 2.0)
        
        let finalPoistion = CGPointMake(self.boraderLayer.frame.minX + 10, self.boraderLayer.frame.minY - targetHeight / 2.0)
        
        
        var scaleTrans = CGAffineTransformMakeScale(scale, scale)
        
        let finalTarns = CGAffineTransformTranslate(scaleTrans, (finalPoistion.x - transPostion.x) / scale,
                                                    (finalPoistion.y - transPostion.y) / scale)
        
        self.placeHorlderLabel.transform = finalTarns
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.changeToStateAnimate(state: .editingOrContent)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == nil || textField.text!.isEmpty {
            self.changeToStateAnimate(state: .empty)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    //
    @objc func clickRightBtn() {
        rightBtnActionBlock?(self)
    }
    
    
    @objc func textFiledValueChanged(textFiled:UITextField) {
        
        //value changed,
        self.callBack?(textFiled.text)
        
    }
        
}
