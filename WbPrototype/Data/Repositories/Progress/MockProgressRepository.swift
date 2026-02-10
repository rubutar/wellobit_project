////
////  MockProgressRepository.swift
////  WbPrototype
////
////  Created by Rudi Butarbutar on 04/02/26.
////
//
//
//final class MockProgressRepository: ProgressRepository {
//
//    func getProgress(currentSequence: Int) async -> [BadgeProgress] {
//
//        [
//            makeRootedCalm(currentSequence),
//            makeBloomingStrong(currentSequence),
//            makeSteadyGrowth(currentSequence)
//        ]
//    }
//
//    // MARK: - Progress mapping
//
//    private func makeRootedCalm(_ seq: Int) -> BadgeProgress {
//        if seq >= 1 {
//            return BadgeProgress(
//                id: MockBadges.rootedCalm.id,
//                badge: MockBadges.rootedCalm.withEarnedDateIfNeeded(seq >= 1),
//                status: .earned,
//                remainingSessions: nil
//            )
//        }
//
//        return BadgeProgress(
//            id: MockBadges.rootedCalm.id,
//            badge: MockBadges.rootedCalm,
//            status: .locked,
//            remainingSessions: nil
//        )
//    }
//
//    private func makeBloomingStrong(_ seq: Int) -> BadgeProgress {
//        if seq >= 2 {
//            return BadgeProgress(
//                id: MockBadges.bloomingStrong.id,
//                badge: MockBadges.bloomingStrong.withEarnedDateIfNeeded(seq >= 2),
//                status: seq == 2 ? .active : .earned,
//                remainingSessions: seq == 2 ? 4 : nil
//            )
//        }
//
//        return BadgeProgress(
//            id: MockBadges.bloomingStrong.id,
//            badge: MockBadges.bloomingStrong,
//            status: .locked,
//            remainingSessions: nil
//        )
//    }
//
//    private func makeSteadyGrowth(_ seq: Int) -> BadgeProgress {
//        if seq >= 3 {
//            return BadgeProgress(
//                id: MockBadges.steadyGrowth.id,
//                badge: MockBadges.steadyGrowth.withEarnedDateIfNeeded(seq >= 3),
//                status: seq == 3 ? .active : .earned,
//                remainingSessions: seq == 3 ? 4 : nil
//            )
//        }
//
//        return BadgeProgress(
//            id: MockBadges.steadyGrowth.id,
//            badge: MockBadges.steadyGrowth,
//            status: .locked,
//            remainingSessions: nil
//        )
//    }
//}
//
