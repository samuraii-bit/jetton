import "@stdlib/ownable";

// Since v1.6.0, Tact has a contract parameters syntax that can supersede
// lazy initialization by init() for all contracts that do not require specific on-chain
// deployment logic that must be run only once in the `init()` function.
//
// Note that the empty parameter list above is still a parameter list,
// meaning that the contract won't have an implicit or explicit `init(){:tact}` function
// and will enjoy storage write optimizations and use less gas overall.
//
// See: https://docs.tact-lang.org/book/contracts/#parameters
import "./todo_child";
import "./messages";

contract TodoParent with Ownable{
    // Empty receiver for the deployment,
    // which expects the `null` message body
    owner: Address;
    seqno: Int as uint256 = 0;

    init() {
        self.owner = sender();
    }

    receive() {
        // Forward the remaining value in the
        // incoming message back to the sender
        // cashback(sender());
    }

    receive(msg: TodoCreate) {
        self.requireOwner();
        self.seqno += 1;

        let init: StateInit = initOf TodoChild(myAddress(), self.seqno);
        send(SendParameters {
            to: contractAddress(init),
            value: ton("0.2"),
            mode: SendIgnoreErrors,
            data: init.data,
            code: init.code,
            body: InternalSet {todo: msg.todo}.toCell()
        });

        send(SendParameters{
            to: sender(),
            value: 0,
            mode: SendIgnoreErrors + SendRemainingValue,
            body: NewTodoResponse {seqno: self.seqno}.toCell(),
        });
    }

    receive(msg: CompleteTodo) {
        self.requireOwner();
        self.requireTodoExists(msg.seqno);

        send(SendParameters{
            to: contractAddress(initOf TodoChild(myAddress(), msg.seqno)),
            value: 0,
            mode: SendIgnoreErrors + SendRemainingValue,
            body: InternalComplete {excess: sender()}.toCell()
        });
    }

    receive(msg: ChangeTodo) {
        self.requireOwner();
        self.requireTodoExists(msg.seqno);

        send(SendParameters{
            to: contractAddress(initOf TodoChild(myAddress(), msg.seqno)),
            value: 0,
            mode: SendIgnoreErrors + SendRemainingValue,
            body: InternalChange {newTodo: msg.newTodo}.toCell()
        });
    }

    fun requireTodoExists(seqno: Int) {
        require(seqno <= self.seqno && seqno != 0, "Todo doesn't exist");
    }

    get fun seqno(): Int {
        return self.seqno;
    }

    get fun todoAddress(id: Int): Address {
        return contractAddress(initOf TodoChild(myAddress(), self.seqno));
    } 
}
