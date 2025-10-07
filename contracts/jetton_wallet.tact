import "@stdlib/ownable";
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
contract JettonWallet with Ownable {
    balance: Int as coins;
    parent: Address; 
    owner: Address;

    init(parent: Address, owner: Address) {
        self.balance = 0;
        self.parent = parent;
        self.owner = owner;
    }

    receive(msg: InternalAdd) {
        if (msg.origin == self.parent) {
            require(sender() == self.parent, "msg.origin not equals parent");
        } else {
            let init: StateInit = initOf JettonWallet(self.parent, msg.origin);
            require(sender() == contractAddress(init), "different token fault");
        }
        self.balance += msg.amount;
    }

    receive(msg: Transfer) {
        self.requireOwner();
        require(self.balance >= msg.amount, "Insufficient balance");
        self.balance -= msg.amount;

        let init: StateInit = initOf JettonWallet(self.parent, msg.to);
        send(SendParameters{
            to: contractAddress(init),
            value: ton("0.2"),
            mode: SendIgnoreErrors,
            body: InternalAdd {amount: msg.amount, origin: self.owner}.toCell(),
            code: init.code,
            data: init.data
        });

        self.reply("transferred".asComment());
    }
}
