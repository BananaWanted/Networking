#!/usr/bin/env python3
import asyncio


async def run(execution, *args):
    """
    :param execution: an callable
    :param args: Optional, args passed to callable
    :return: return value from the callable
    """
    return await asyncio.get_event_loop().run_in_executor(None, execution, *args)

arun = run
