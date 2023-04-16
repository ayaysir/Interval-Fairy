//
//  StatusManager.swift
//  Interval Gotchi
//
//  Created by 윤범태 on 2023/04/15.
//

import Foundation

/*
 * 간식 => 별처럼 내려옴 (누르면 소리가 나면서 효과로 어떤 음인지 알려줌)
     * 기분 좋아지는 효과 및 배고픔 해결
     * 누르지 않으면 밑에 쌓임 => 시간이 지나면 페이드아웃 되면서 없어짐
     *
 * 놀이 => 음정 맞추기 놀이 (내가 피아노를 눌러 음정을 맞추면 다마고치가 좋아함)
     * 맞춘 경우 : 행복도 증가
     * 틀린 경우: 게임 패배
 * 병 걸린 경우 => 미션으로 x 음정 x도 누르면 해결
 * 목욕 =>
 * 체중계 => 식사, 간식을 많이 먹으면 늘어나고 과체중인 경우 병걸릴 확률 높아짐
 * 훈육 => 미션으로 x 음정 x도 누르면 해결

 앱이 켜져있는 동안(=> 다마고치 화면이 나오는 동안)에는 항상 시간별 계산해야 함
 앱이 백그라운드나 다른 곳에 있다가 화면이 보이면 그 시점에서 재계산해야함
 
 파라미터 (visible)
 * age(표기 단수, 내부 10000) => 시간이 지나거나, aug/dim을 누르면 해당 도수만큼 증감
  max: 10000
  1분당 8씩 증가
  aug당 40씩 증가
  dim당 20씩 감소
 
 * 무게(표기: g, 내부: mg) => 기본 10g, 간식을 먹으면 10% 증가, 시간이 지나거나 게임을 하면 감소
  max: 100,000
  age별 기본값: 10000, 20000, 30000, 40000, 50000, 70000, 100000, 150000, 200000, 500000
  1분당 0.02% 감소
  게임시 전체 무게의 10% 감소
  과체중: age 기본값 대비 2배 이상
 
 * Discipline => 시간 지나면 일정 부분 감소하고, 무게, 행복, 배고픔에 복합적으로 영향받음
  max: 10000(높을수록 규율적임)
  기본 1분당 15 감소
  음정 페어 맞추면 5 증가
  과체중시 5 추가 감소
  행복 max값인 경우 10 추가 감소, 행복값에 비례
  배고픔 수치에 따라 최대 10 추가 감소, 배고픔 값에 비례
  말안들음: 3000 이하 (모든 명령이 안먹힘 => 미션으로 해결)
 
 * Satiety => 포만감, 시간 지나거나 게임을 하면 배고픔
   필요한 경우 게임 내에서는 Hungry로 표시
   max: 10000 (높을수록 배안고픔)
   기본 1분당 30 감소
   과체중시 10 추가 감소
   행복 max값인 경우 10 증가, 행복값에 비례
   게임 시 1000 감소
   별 먹기: 1000 증가
   음정 페어 맞추면 100 증가
   말안들음: 3000 이하 (간식 증가 외에 모든 명령이 안먹힘)
   
 * Happy => 장/단 음정에 따라 증감, 게임에서 이기면 증가
   max: 10000 (높을수록 행복함)
   장음정/완전음정 맞추면 1000 증가
   단음정/증음정/감음정 맞추면 1000 감소
   게임에서 승리 시 6000 증가 / 패배 시 3000 감소
   
 (invisible parameter)
 * 위생 => 시간에 따라 더러워짐 + 완전, 증감 음정을 누르면 증감
   max: 10000 (높을수록 깨끗함)
   기본 1분당 10 감소
   간식 먹으면 1000 감소
   게임 하면 2000 감소
   증음정 맞추면 5000 증가
   감음정 맞추면 1000 감소
   말안들음: 2000 이하 (증음정 외에 모든 명령이 안먹힘)
  
 * 건강 => 시간에 따라 병걸림 + 과체중인 경우 확률 증가 + 무게, 행복, 배고픔에 복합적으로 영향받음
   max: 10000 (높을수록 건강함)
   기본 1분당 10 감소
   간식 먹으면 100 감소
   게임 하면 50 감소
   단음정 맞추면 100 감소
   감음정 맞추면 200 증가
   완전음정 맞추면 100 증가
 
 * Perfectness
   max: 10000
   완전음정 맞추면 200 ~ 1000 랜덤 증가
   그 외의 음정 맞추면 100 ~ 500 랜덤 감소
   시간 영향 없음
 
 * AugDim
   max: 10000
   증음정 맞추면 500 ~ 1000 증가
   감음정 맞추면 500 ~ 1000 감소
   시간 영향 없음
 
 장단 => 감정, 표정의 여부 => happy
 왼전 => 다마고치의 형태가 더 그럴싸해짐(찌그러지지 않음) (대략 5단계) =>
 증감 => 나이의 증감 및 장식의 증감(계절, 나무, age와는 별개)

 파라미터 (invisible)
 */
extension String {
    // visible
    static let stkAge = "STATUS_AGE"
    static let stkWeight = "STATUS_WEIGHT"
    static let stkDiscipline = "STATUS_DISCIPLINE"
    static let stkSatiety = "STATUS_SATIETY"
    static let stkHappy = "STATUS_HAPPY"
    
    // invisible
    static let stkHelath = "STATUS_HEALTH"
    static let stkHygiene = "STATUS_HYGIENE"
    static let stkPerfectness = "STATUS_PERFECTNESS"
    static let stkAugDim = "STATUS_AUGDIM"
}

class StatusManager {
    static var shared = StatusManager()
    
    var localStorage = UserDefaults.standard
    
    func limitValue(_ number: Int, min: Int = 0, max: Int) -> Int {
        return number < min ? min : number > max ? max : number
    }
    
    var age: Int {
        get {
            localStorage.integer(forKey: .stkAge)
        } set {
            localStorage.set(limitValue(newValue, max: 10000), forKey: .stkAge)
        }
    }
    
    var weight: Int {
        get {
            localStorage.integer(forKey: .stkWeight)
        } set {
            localStorage.set(limitValue(newValue, max: 100000), forKey: .stkWeight)
        }
    }
    
    var discipline: Int {
        get {
            localStorage.integer(forKey: .stkDiscipline)
        } set {
            localStorage.set(limitValue(newValue, max: 10000), forKey: .stkDiscipline)
        }
    }
    
    var satiety: Int {
        get {
            localStorage.integer(forKey: .stkSatiety)
        } set {
            localStorage.set(limitValue(newValue, max: 10000), forKey: .stkSatiety)
        }
    }
    
    var happy: Int {
        get {
            localStorage.integer(forKey: .stkHappy)
        } set {
            localStorage.set(limitValue(newValue, max: 10000), forKey: .stkHappy)
        }
    }
    
    var health: Int {
        get {
            localStorage.integer(forKey: .stkHelath)
        } set {
            localStorage.set(limitValue(newValue, max: 10000), forKey: .stkHelath)
        }
    }
    
    var hygiene: Int {
        get {
            localStorage.integer(forKey: .stkHygiene)
        } set {
            localStorage.set(limitValue(newValue, max: 10000), forKey: .stkHygiene)
        }
    }
    
    var perfectness: Int {
        get {
            localStorage.integer(forKey: .stkPerfectness)
        } set {
            localStorage.set(limitValue(newValue, max: 10000), forKey: .stkPerfectness)
        }
    }
    
    var augDim: Int {
        get {
            localStorage.integer(forKey: .stkAugDim)
        } set {
            localStorage.set(limitValue(newValue, max: 10000), forKey: .stkAugDim)
        }
    }
}
