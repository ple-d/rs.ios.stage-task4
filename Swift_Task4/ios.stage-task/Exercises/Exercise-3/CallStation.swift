import Foundation

final class CallStation {
    var userStorage: Set<User> = []
    var callStorage: [CallID: Call] = [:]
    var userCurrentCallStorage: [UUID: Call] = [:]
}

extension User: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension CallStation: Station {
    
    func users() -> [User] {
        Array(userStorage)
    }
    
    func add(user: User) {
        userStorage.insert(user)
    }
    
    func remove(user: User) {
        userStorage.remove(user)
    }
    
    func execute(action: CallAction) -> CallID? {
        switch action {
        case let .start(from: fromUser, to: toUser):
            
            let callId = CallID()
            if !userStorage.contains(fromUser) {
                return nil
            }
            if !(userStorage.contains(toUser)) {
                let call = Call(id: callId, incomingUser: fromUser, outgoingUser: toUser, status: .ended(reason: .error))
                callStorage[callId] = call
                userCurrentCallStorage[fromUser.id] = nil
                userCurrentCallStorage[toUser.id] = nil
                return call.id
            }
            if currentCall(user: toUser) != nil {
                let call = Call(id: callId, incomingUser: fromUser, outgoingUser: toUser, status: .ended(reason: .userBusy))
                callStorage[callId] = call
                return call.id
            }
            let call = Call(id: callId, incomingUser: fromUser, outgoingUser: toUser, status: .calling)
            callStorage[callId] = call
            userCurrentCallStorage[fromUser.id] = call
            userCurrentCallStorage[toUser.id] = call
            return callId
            
        case let .answer(from: answeringUser):
            guard let call = currentCall(user: answeringUser) else {
                return nil
            }
            let callingUser = call.incomingUser
            if !userStorage.contains(callingUser) || !userStorage.contains(answeringUser) {
                let errorCall = Call(id: call.id, incomingUser: callingUser, outgoingUser: answeringUser, status: .ended(reason: .error))
                callStorage[errorCall.id] = errorCall
                userCurrentCallStorage[answeringUser.id] = nil
                userCurrentCallStorage[callingUser.id] = nil
                return nil
            }
            
            if let answeringUserCall = currentCall(user: answeringUser) {
                if (answeringUserCall.status != .calling || answeringUserCall.id != call.id) {
                    let errorCall = Call(id: call.id, incomingUser: callingUser, outgoingUser: answeringUser, status: .ended(reason: .error))
                    callStorage[errorCall.id] = errorCall
                    userCurrentCallStorage[answeringUser.id] = nil
                    userCurrentCallStorage[callingUser.id] = nil
                    return nil
                }
                let successCall = Call(id: call.id, incomingUser: callingUser, outgoingUser: answeringUser, status: .talk)
                callStorage[successCall.id] = successCall
                userCurrentCallStorage[answeringUser.id] = successCall
                userCurrentCallStorage[callingUser.id] = successCall
                return successCall.id
            }
            return call.id
        case let .end(from: fromUser):
            guard let call = currentCall(user: fromUser) else { return nil }
            let toUser = call.incomingUser.id == fromUser.id ? call.outgoingUser : call.incomingUser
            if !userStorage.contains(fromUser) || !userStorage.contains(toUser) {
                let errorCall = Call(id: call.id, incomingUser: call.incomingUser, outgoingUser: call.outgoingUser, status: .ended(reason: .error))
                callStorage[errorCall.id] = errorCall
                userCurrentCallStorage[fromUser.id] = nil
                userCurrentCallStorage[toUser.id] = nil
                return nil
            }
            if (currentCall(user: toUser)?.status != .talk) {
                let errorCall = Call(id: call.id, incomingUser: call.incomingUser, outgoingUser: call.outgoingUser, status: .ended(reason: .cancel))
                callStorage[errorCall.id] = errorCall
                userCurrentCallStorage[fromUser.id] = nil
                userCurrentCallStorage[toUser.id] = nil
                return errorCall.id
            }
            let endCall = Call(id: call.id, incomingUser: call.incomingUser, outgoingUser: call.outgoingUser, status: .ended(reason: .end))
            callStorage[endCall.id] = endCall
            userCurrentCallStorage[fromUser.id] = nil
            userCurrentCallStorage[toUser.id] = nil
            return endCall.id
        }
    }
    
    func calls() -> [Call] {
        Array(callStorage.values)
    }
    
    func calls(user: User) -> [Call] {
        Array(callStorage.values.filter { $0.incomingUser.id == user.id || $0.outgoingUser.id == user.id})
    }
    
    func call(id: CallID) -> Call? {
        callStorage[id]
    }
    
    func currentCall(user: User) -> Call? {
        userCurrentCallStorage[user.id]
    }
}
