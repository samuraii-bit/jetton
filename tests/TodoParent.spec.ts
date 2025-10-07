import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { ChangeTodo, TodoParent } from '../build/TodoParent/TodoParent_TodoParent';
import { CompleteTodo, TodoChild, TodoCreate } from '../build/TodoChild/TodoChild_TodoChild';

import '@ton/test-utils';

describe('TodoParent', () => {

    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let todoParent: SandboxContract<TodoParent>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        todoParent = blockchain.openContract(await TodoParent.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await todoParent.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            null,
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: todoParent.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and todoParent are ready to use
    });

    it('should create todo', async () => {
        const todoCreateMessage: TodoCreate = {
            $$type: "TodoCreate",
            todo: "make dinner"
        }

        await todoParent.send(
            deployer.getSender(),
            {
                value: toNano("0.2"),
            },
            todoCreateMessage
        );

        const todoChildAddress = await todoParent.getTodoAddress(1n);
        const todoChild = blockchain.openContract(TodoChild.fromAddress(todoChildAddress));
        
        const isTodoCompleted = await todoChild.getCompleted();
        const todo = await todoChild.getTodo();

        expect(isTodoCompleted).toEqual(false);
        expect(todo).toEqual("make dinner");
    });

    it("should change Todo", async () => {
        const todoCreateMessage: TodoCreate = {
            $$type: "TodoCreate",
            todo: "make dinner"
        }

        await todoParent.send(
            deployer.getSender(),
            {
                value: toNano("0.2"),
            },
            todoCreateMessage
        );

        const todoChildAddress = await todoParent.getTodoAddress(1n);
        const todoChild = blockchain.openContract(TodoChild.fromAddress(todoChildAddress));

        const todoChangeMessage: ChangeTodo = {
            $$type: "ChangeTodo", 
            newTodo: "make breakfast",
            seqno: 1n
        }

        await todoParent.send(
            deployer.getSender(),
            {
                value: toNano("0.2"),
            },
            todoChangeMessage
        );

        const todo = await todoChild.getTodo();
        expect(todo).toEqual("make breakfast");
    })

    it("should complete", async () => {
        const todoCreateMessage: TodoCreate = {
            $$type: "TodoCreate",
            todo: "make dinner"
        }

        await todoParent.send(
            deployer.getSender(),
            {
                value: toNano("0.2"),
            },
            todoCreateMessage
        );

        const todoChildAddress = await todoParent.getTodoAddress(1n);
        const todoChild = blockchain.openContract(TodoChild.fromAddress(todoChildAddress));

        const completeTodoMessage: CompleteTodo = {
            $$type: "CompleteTodo", 
            seqno: 1n
        }

        await todoParent.send(
            deployer.getSender(),
            {
                value: toNano("0.2"),
            },
            completeTodoMessage
        );

        const isTodoCompleted = await todoChild.getCompleted();
        expect(isTodoCompleted).toEqual(true);
    })
});
