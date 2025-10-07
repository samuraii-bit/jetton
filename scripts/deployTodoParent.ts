import { toNano } from '@ton/core';
import { TodoParent } from '../build/TodoParent/TodoParent_TodoParent';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const todoParent = provider.open(await TodoParent.fromInit());

    await todoParent.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        null,
    );

    await provider.waitForDeploy(todoParent.address);

    // run methods on `todoParent`
}
