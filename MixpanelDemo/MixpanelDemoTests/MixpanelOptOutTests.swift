//
//  MixpanelOptOutTests.swift
//  MixpanelDemoTests
//
//  Created by Zihe Jia on 3/27/18.
//  Copyright © 2018 Mixpanel. All rights reserved.
//

import XCTest
@testable import Mixpanel

class MixpanelOptOutTests: MixpanelBaseTests {
    
    func testHasOptOutTrackingFlagBeingSetProperlyAfterInitializedWithOptedOutYES()
    {
        let testMixpanel = Mixpanel.initialize(token: randomId(), optOutTrackingByDefault: true)
        waitForTrackingQueue(testMixpanel)
        XCTAssertTrue(testMixpanel.hasOptedOutTracking(), "When initialize with opted out flag set to YES, the current user should have opted out tracking")
        testMixpanel.reset()
        removeDBfile(testMixpanel.apiToken)
    }

    func testOptInWillAddOptInEvent()
    {
        let testMixpanel = Mixpanel.initialize(token: randomId(), optOutTrackingByDefault: true)
        testMixpanel.optInTracking()
        XCTAssertFalse(testMixpanel.hasOptedOutTracking(), "The current user should have opted in tracking")
        waitForTrackingQueue(testMixpanel)
        XCTAssertTrue(eventQueue(token: testMixpanel.apiToken).count == 1, "When opted in, event queue should have one even(opt in) being queued")

        if eventQueue(token: testMixpanel.apiToken).count > 0 {
            let event = eventQueue(token: testMixpanel.apiToken).first
            XCTAssertEqual((event!["event"] as? String), "$opt_in", "When opted in, a track '$opt_in' should have been queued")
        }
        else {
            XCTAssertTrue(eventQueue(token: testMixpanel.apiToken).count == 1, "When opted in, event queue should have one even(opt in) being queued")
        }
        removeDBfile(testMixpanel.apiToken)
    }

    func testOptInTrackingForDistinctId()
    {
        let testMixpanel = Mixpanel.initialize(token: randomId(), optOutTrackingByDefault: true)
        testMixpanel.optInTracking(distinctId: "testDistinctId")
        XCTAssertFalse(testMixpanel.hasOptedOutTracking(), "The current user should have opted in tracking")
        waitForTrackingQueue(testMixpanel)
        sleep(1)
        let event1 = eventQueue(token: testMixpanel.apiToken).first
        let event2 = eventQueue(token: testMixpanel.apiToken).last
        XCTAssertTrue((event1!["event"] as? String) == "$opt_in" || (event2!["event"] as? String) == "$opt_in", "When opted in, a track '$opt_in' should have been queued")
        XCTAssertEqual(testMixpanel.distinctId, "testDistinctId", "mixpanel identify failed to set distinct id")
        XCTAssertEqual(testMixpanel.people.distinctId, "testDistinctId", "mixpanel identify failed to set people distinct id")
        XCTAssertTrue(unIdentifiedPeopleQueue(token: testMixpanel.apiToken).count == 0, "identify: should move records from unidentified queue")
        removeDBfile(testMixpanel.apiToken)
    }

    func testOptInTrackingForDistinctIdAndWithEventProperties()
    {
        let now = Date()
        let testProperties: Properties = ["string": "yello",
            "number": 3,
            "date": now,
            "$app_version": "override"]
        let testMixpanel = Mixpanel.initialize(token: randomId(), optOutTrackingByDefault: true)
        testMixpanel.optInTracking(distinctId: "testDistinctId", properties: testProperties)
        waitForTrackingQueue(testMixpanel)
        sleep(1)
        let eventQueueValue = eventQueue(token: testMixpanel.apiToken)
        
        let props = eventQueueValue.first!["properties"] as? InternalProperties
        XCTAssertEqual(props!["string"] as? String, "yello")
        XCTAssertEqual(props!["number"] as? NSNumber, 3)
        compareDate(dateString: props!["date"] as! String, dateDate: now)
        XCTAssertEqual(props!["$app_version"] as? String, "override", "reserved property override failed")

        if eventQueueValue.count > 0 {
            let event = eventQueueValue.first
            XCTAssertEqual((event!["event"] as? String), "$opt_in", "When opted in, a track '$opt_in' should have been queued")
        }
        else {
            XCTAssertTrue(eventQueueValue.count == 1, "When opted in, event queue should have one even(opt in) being queued")
        }

        XCTAssertEqual(testMixpanel.distinctId, "testDistinctId", "mixpanel identify failed to set distinct id")
        XCTAssertEqual(testMixpanel.people.distinctId, "testDistinctId", "mixpanel identify failed to set people distinct id")
        XCTAssertTrue(unIdentifiedPeopleQueue(token: testMixpanel.apiToken).count == 0, "identify: should move records from unidentified queue")
        removeDBfile(testMixpanel.apiToken)
    }

    func testHasOptOutTrackingFlagBeingSetProperlyForMultipleInstances()
    {
        let mixpanel1 = Mixpanel.initialize(token: randomId(), optOutTrackingByDefault: true)
        XCTAssertTrue(mixpanel1.hasOptedOutTracking(), "When initialize with opted out flag set to YES, the current user should have opted out tracking")
        removeDBfile(mixpanel1.apiToken)

        let mixpanel2 = Mixpanel.initialize(token: randomId(), optOutTrackingByDefault: false)
        XCTAssertFalse(mixpanel2.hasOptedOutTracking(), "When initialize with opted out flag set to NO, the current user should have opted in tracking")
        removeDBfile(mixpanel2.apiToken)
    }

    func testHasOptOutTrackingFlagBeingSetProperlyAfterInitializedWithOptedOutNO()
    {
        let testMixpanel = Mixpanel.initialize(token: randomId(), optOutTrackingByDefault: false)
        XCTAssertFalse(testMixpanel.hasOptedOutTracking(), "When initialize with opted out flag set to NO, the current user should have opted out tracking")
        removeDBfile(testMixpanel.apiToken)
    }

    func testHasOptOutTrackingFlagBeingSetProperlyByDefault()
    {
        let testMixpanel = Mixpanel.initialize(token: randomId())
        XCTAssertFalse(testMixpanel.hasOptedOutTracking(), "By default, the current user should not opted out tracking")
        removeDBfile(testMixpanel.apiToken)
    }

    func testHasOptOutTrackingFlagBeingSetProperlyForOptOut()
    {
        let testMixpanel = Mixpanel.initialize(token: randomId(), optOutTrackingByDefault: true)
        testMixpanel.optOutTracking()
        XCTAssertTrue(testMixpanel.hasOptedOutTracking(), "When optOutTracking is called, the current user should have opted out tracking")
        removeDBfile(testMixpanel.apiToken)
    }

    func testHasOptOutTrackingFlagBeingSetProperlyForOptIn()
    {
        let testMixpanel = Mixpanel.initialize(token: randomId(), optOutTrackingByDefault: true)
        testMixpanel.optOutTracking()
        XCTAssertTrue(testMixpanel.hasOptedOutTracking(), "When optOutTracking is called, the current user should have opted out tracking")
        testMixpanel.optInTracking()
        XCTAssertFalse(testMixpanel.hasOptedOutTracking(), "When optOutTracking is called, the current user should have opted in tracking")
        removeDBfile(testMixpanel.apiToken)
    }

    func testOptOutTrackingWillNotGenerateEventQueue()
    {
        let testMixpanel = Mixpanel.initialize(token: randomId(), optOutTrackingByDefault: true)
        testMixpanel.optOutTracking()
        for i in 0..<50 {
            testMixpanel.track(event: "event \(i)")
        }
        waitForTrackingQueue(testMixpanel)
        XCTAssertTrue(eventQueue(token: testMixpanel.apiToken).count == 0, "When opted out, events should not be queued")
        removeDBfile(testMixpanel.apiToken)
    }

    func testOptOutTrackingWillNotGeneratePeopleQueue()
    {
        let testMixpanel = Mixpanel.initialize(token: randomId(), optOutTrackingByDefault: true)
        testMixpanel.optOutTracking()
        for i in 0..<50 {
            testMixpanel.people.set(property: "p1", to: "\(i)")
        }
        waitForTrackingQueue(testMixpanel)
        XCTAssertTrue(peopleQueue(token: testMixpanel.apiToken).count == 0, "When opted out, events should not be queued")
        removeDBfile(testMixpanel.apiToken)
    }

    func testOptOutTrackingWillSkipAlias()
    {
        let testMixpanel = Mixpanel.initialize(token: randomId(), optOutTrackingByDefault: true)
        testMixpanel.optOutTracking()
        testMixpanel.createAlias("testAlias", distinctId: "aDistinctId")
        XCTAssertNotEqual(testMixpanel.alias, "testAlias", "When opted out, alias should not be set")
        removeDBfile(testMixpanel.apiToken)
    }

    func testEventBeingTrackedBeforeOptOutShouldNotBeCleared()
    {
        let testMixpanel = Mixpanel.initialize(token: randomId())
        testMixpanel.track(event: "a normal event")
        waitForTrackingQueue(testMixpanel)
        XCTAssertTrue(eventQueue(token: testMixpanel.apiToken).count == 2, "events should be queued")
        testMixpanel.optOutTracking()
        waitForTrackingQueue(testMixpanel)
        XCTAssertTrue(eventQueue(token: testMixpanel.apiToken).count == 2, "When opted out, any events tracked before opted out should not be cleared")
        removeDBfile(testMixpanel.apiToken)
    }

    func testOptOutTrackingRegisterSuperProperties()
    {
        let testMixpanel = Mixpanel.initialize(token: randomId(), optOutTrackingByDefault: true)
        let properties: Properties = ["p1": "a", "p2": 3, "p3": Date()]
        testMixpanel.optOutTracking()
        testMixpanel.registerSuperProperties(properties)
        waitForTrackingQueue(testMixpanel)
        XCTAssertNotEqual(NSDictionary(dictionary: testMixpanel.currentSuperProperties()),
                       NSDictionary(dictionary: properties),
                       "When opted out, register super properties should not be successful")
        removeDBfile(testMixpanel.apiToken)
    }

    func testOptOutTrackingRegisterSuperPropertiesOnce()
    {
        let testMixpanel = Mixpanel.initialize(token: randomId(), optOutTrackingByDefault: true)
        let properties: Properties = ["p1": "a", "p2": 3, "p3": Date()]
        testMixpanel.optOutTracking()
        testMixpanel.registerSuperPropertiesOnce(properties)
        waitForTrackingQueue(testMixpanel)
        XCTAssertNotEqual(NSDictionary(dictionary: testMixpanel.currentSuperProperties()),
                              NSDictionary(dictionary: properties),
                          "When opted out, register super properties once should not be successful")
        removeDBfile(testMixpanel.apiToken)
    }

    func testOptOutWilSkipTimeEvent()
    {
        let testMixpanel = Mixpanel.initialize(token: randomId(), optOutTrackingByDefault: true)
        testMixpanel.optOutTracking()
        testMixpanel.time(event: "400 Meters")
        testMixpanel.track(event: "400 Meters")
        waitForTrackingQueue(testMixpanel)
        XCTAssertNil(eventQueue(token:testMixpanel.apiToken).last, "When opted out, this event should not be timed.")
        removeDBfile(testMixpanel.apiToken)
    }

    func testOptOutWillSkipFlushPeople()
    {
        let testMixpanel = Mixpanel.initialize(token: randomId(), optOutTrackingByDefault: true)
        testMixpanel.optInTracking()
        testMixpanel.identify(distinctId: "d1")
        waitForTrackingQueue(testMixpanel)
        for i in 0..<1 {
            testMixpanel.people.set(property: "p1", to: "\(i)")
        }
        waitForTrackingQueue(testMixpanel)
        XCTAssertTrue(peopleQueue(token: testMixpanel.apiToken).count == 1, "When opted in, people queue should have been queued")

        testMixpanel.optOutTracking()
        waitForTrackingQueue(testMixpanel)

        testMixpanel.flush()
        waitForTrackingQueue(testMixpanel)
        XCTAssertTrue(peopleQueue(token: testMixpanel.apiToken).count == 3, "When opted out, people queue should not be flushed and 2 more people being set")
        removeDBfile(testMixpanel.apiToken)
    }

    func testOptOutWillSkipFlushEvent()
    {
        let testMixpanel = Mixpanel.initialize(token: randomId(), optOutTrackingByDefault: true)
        testMixpanel.optInTracking()
        testMixpanel.identify(distinctId: "d1")
        waitForTrackingQueue(testMixpanel)
        for i in 0..<1 {
            testMixpanel.track(event: "event \(i)")
        }
        waitForTrackingQueue(testMixpanel)
        XCTAssertTrue(eventQueue(token: testMixpanel.apiToken).count == 3, "When opted in, events should have been queued")

        testMixpanel.optOutTracking()
        waitForTrackingQueue(testMixpanel)

        testMixpanel.flush()
        waitForTrackingQueue(testMixpanel)
        
        XCTAssertTrue(eventQueue(token: testMixpanel.apiToken).count == 3, "When opted out, events should not be flushed")
        removeDBfile(testMixpanel.apiToken)
    }
}
