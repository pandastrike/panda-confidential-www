### Symmetric Encryption

> **Warning**: Private keys should only be accessible to their owners.

```coffeescript
import {confidential} from "panda-confidential"
{encrypt, Message} = confidential()
import {keyLookup, write} from "my-library"

do ->
  alice = keyLookup "Alice/private"

  plaintext = Message.from "utf8", "Hello, Alice!"

  envelope = await encrypt alice, plaintext

  # You may serialize with the instance method `to`
  write "greeting", envelope.to "base64"
```
