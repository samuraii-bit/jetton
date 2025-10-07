import "./messages";

// Since v1.6.0, Tact has a contract parameters syntax that can supersede
// lazy initialization by init() for all contracts that do not require specific on-chain
// deployment logic that must be run only once in the `init()` function.
//
// Note that the empty parameter list above is still a parameter list,
// meaning that the contract won't have an implicit or explicit `init(){:tact}` function
// and will enjoy storage write optimizations and use less gas overall.
//
// See: https://docs.tact-lang.org/book/contracts/#parameters

contract TodoChild {
    // Empty receiver for the deployment,
    // which expects the `null` message body
    todo: String;
    parent: Address;
    seqno: Int as uint256;
    completed: Bool;

    init(parent: Address, seqno: Int) {
        self.parent = parent;
        self.seqno = seqno;
        self.completed = false;
        self.todo = "";
    }

    receive (msg: InternalSet) {
        self.requireParent();
        self.todo = msg.todo;
    }

    receive(msg: InternalComplete) {
        self.requireParent();
        self.completed = true;
        send(SendParameters {
            to: msg.excess,
            value: 0,
            mode: SendIgnoreErrors + SendRemainingValue
        })
    }

    receive(msg: InternalChange) {
        self.requireParent();
        self.todo = msg.newTodo;
    }

    fun requireParent() {
        require(sender() == self.parent, "Only parent can use this function");
    }

    get fun todo(): String {
        return self.todo;
    } 
    
    get fun completed(): Bool {
        return self.completed;
    }

    receive() {
        // Forward the remaining value in the
        // incoming message back to the sender
        // cashback(sender());
    }
}
