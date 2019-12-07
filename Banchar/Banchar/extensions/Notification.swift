

import Foundation
import UserNotifications

extension Notification.Name {
    static let cardsChanged = Notification.Name("cardsChanged")
    static let fareChanged = Notification.Name("fareChanged")
    static let closeKeyboard = Notification.Name("closeKeyboard")

}

func doWhen( _ item: AnyObject, did: NSNotification.Name, _ action: @escaping ()->() ) {
    NotificationCenter.default.addObserver(forName: did, object: item, queue: OperationQueue.main) { (note) in
        action()
    }
}
func doWhen( _ did: NSNotification.Name, _ action: @escaping ()->() ) {
    NotificationCenter.default.addObserver(forName: did, object: nil, queue: OperationQueue.main) { (note) in
        action()
    }
}

func newNotification(_ name: Notification.Name, _ action: @escaping ()->()) -> NotificationCenter {
    func handler(notification: Notification) -> Void {
        action()
    }
    let notification = NotificationCenter.default
    notification.addObserver(forName: name , object:nil, queue:nil, using:handler)
    return notification
}
public func notify(name: Notification.Name) {
    NotificationCenter.default.post(Notification(name: name))
}
