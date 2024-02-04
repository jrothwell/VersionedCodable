# ``VersionKeyAtRootVersionPathSpec``

Types encoded with this ``VersionPathSpec`` look like this:

```json
{
    "name": "Charlie Smith",
    "version": 1
}
```

This is the default behaviour of ``VersionedCodable``. If you are creating a new type, you might want to adopt this behaviour, which requires no additional work over just conforming your type to ``VersionedCodable`` in the usual way.

- Note: If you're decoding existing documents with the version field in a different place, or if the behaviour provided by ``VersionKeyAtRootVersionPathSpec`` is unacceptable for any other reason, you can implement your own ``VersionPathSpec``.

- Warning: ``VersionedCodable`` can't guarantee at compile or run time that there isn't a clashing `version` field on the type on which ``VersionKeyAtRootVersionPathSpec`` is used. As always, the version number is transparent at the point of use---you should not try to set it manually.
