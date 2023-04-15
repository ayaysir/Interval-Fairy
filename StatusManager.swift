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
 * 목욕 => 미션으로 x 음정 x도 누르면 해결
 * 체중계 => 식사, 간식을 많이 먹으면 늘어나고 과체중인 경우 병걸릴 확률 높아짐
 * 훈육 => 미션으로 x 음정 x도 누르면 해결

 
 파라미터 (visible)
 * age => 시간이 지나거나, aug/dim을 누르면 해당 도수만큼 증감
 * 무게(g) => 기본 10g, 간식을 먹으면 x그램 증가, 시간이 지나거나 게임을 하면 감소
 * Discipline => 시간 지나면 일정 부분 감소하고, 무게, 행복, 배고픔에 복합적으로 영향받음
 * Hungry => 시간 지나거나 게임을 하면 증가
 * Happy => 장/단 음정에 따라 증감, 게임에서 이기면 증가
 
 * 위생 => 시간에 따라 더러워짐 + 완전, 증감 음정을 누르면 증감
 * 질병 => 시간에 따라 병걸림 + 과체중인 경우 확률 증가 + 무게, 행복, 배고픔에 복합적으로 영향받음
 
 장단 => 감정, 표정의 여부 => happy
 왼전 => 다마고치의 형태가 더 그럴싸해짐(찌그러지지 않음) (대략 5단계) =>
 증감 => 나이의 증감 및 장식의 증감(계절, 나무, age와는 별개)

 파라미터 (invisible)
 */
extension String {
    static let stkAge = "STATUS_AGE"
    static let stkWeight = "STATUS_WEIGHT"
    static let stkDiscipline = "STATUS_DISCIPLINE"
    static let stkHungry = "STATUS_HUNGRY"
    static let stkHappy = "STATUS_HAPPY"
    
    static let stkPerfectness = "STATUS_PERFECTNESS"
    static let stkAugDim = "STATUS_AUGDIM"
}
