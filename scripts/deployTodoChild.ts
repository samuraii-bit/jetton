import { toNano } from '@ton/core';
import { TodoChild } from '../build/TodoChild/TodoChild_TodoChild';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const todoChild = provider.open(await TodoChild.fromInit());

    await todoChild.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        null,
    );

    await provider.waitForDeploy(todoChild.address);

    // run methods on `todoChild`
}
