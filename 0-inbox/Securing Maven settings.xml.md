
The encrypted version of the master password is encrypted with a [hardcoded key](https://github.com/apache/maven/blob/fe25a2627c1dafeb44188dad9f45dfd5fe965a98/maven-embedder/src/main/java/org/apache/maven/cli/MavenCli.java#L856), so please treat it as if the password is stored in the file in plain text.

```bash
# generate master password
mvn --encrypt-master-password

# produces e.g.
{jSMOWnoPFgsHVpMvz5VrIt5kRbzGpI8u+9EF1iFQyJQ=}

# put it into ~/.m2/settings-security.xml
<settingsSecurity>
	<master>{jSMOWnoPFgsHVpMvz5VrIt5kRbzGpI8u+9EF1iFQyJQ=}</master>
</settingsSecurity>
```

When this is done, you can start encrypting existing server passwords.

```bash
mvn --encrypt-password
```


Add the encrypted values to `settings.xml`

```xml
<settings>
...
  <servers>
...
    <server>
      <id>my.server</id>
      <username>foo</username>
      <password>Oleg reset this password on 2009-03-11, expires on 2009-04-11 {COQLCE6DU6GtcS5P=}</password>
    </server>
...
  </servers>
...
</settings>
```