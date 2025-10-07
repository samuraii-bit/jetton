import "./jetton_wallet";
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

struct MetaData {
    symbol: String;
    totalSupply: Int as coins;
}

contract JettonMaster  {
    symbol: String;
    totalSupply: Int as coins;

    init() {
        self.symbol = "TON";
        self.totalSupply = ton("500");
        self.mint(self.totalSupply, sender());
    }

    fun mint(amount: Int, to: Address) {
        let init: StateInit = initOf JettonWallet(myAddress(), to);

        send(SendParameters{
            to: contractAddress(init),
            value: ton("0.02"),
            mode: SendIgnoreErrors,
            body: InternalAdd {amount: amount, origin: myAddress()}.toCell(),
            code: init.code,
            data: init.data
        });
    }

    get fun walletAddress(owner: Address): Address {
        let init: StateInit = initOf JettonWallet(myAddress(), owner);
        return contractAddress(init);
    }

    get fun metadata(): MetaData {
        return MetaData {symbol: self.symbol, totalSupply: self.totalSupply};
    } 
}
