message TodoCreate {
    todo: String;
}

message InternalSet {
    todo: String;
}

message NewTodoResponse {
    seqno: Int as uint256;
}

message CompleteTodo {
    seqno: Int as uint256;
}

message InternalComplete {
    excess: Address;
}

message ChangeTodo {
    newTodo: String;
    seqno: Int as uint256;
}

message InternalChange {
    newTodo: String;
}

message InternalAdd {
    amount: Int as coins;
    origin: Address
}

message Transfer {
    amount: Int as coins;
    to: Address;
}
