# Arcanus Changelog

## master (unreleased)

  Update `tty` dependency to v0.3+

## 1.1.2

* Update `tty` dependency to v0.2

## 1.1.1

* Remove subprocess require (bugfix)

## 1.1.0

* Remove unused `childprocess` dependency

## 1.0.1

* Update `childprocess` to v0.6.3

## 1.0.0

* **BREAKING CHANGE**: The format of the chest file has been changed
  to support encryption of arbitrarily-long values (previously there
  was a limit due to the algorithm used). To update to the new format,
  run `arcanus show` to get the decrypted chest YAML
  Edit `.arcanus/chest.yaml` and change its contents to `--- {}`. Finally
  run `arcanus edit` and paste the YAML file you previously exported.
* Remove internal `Configuration` class, as it was never used
  (results in no user-facing changes)

## 0.12.1

* Output color escape sequences only when outputting to a TTY console

## 0.12.0

* Respect ARCANUS_PASSWORD environment variable when running arcanus commands
  from the command line

## 0.11.0

* Update minimum Ruby version to 2.1 (due to methods with required keyword
  arguments)
* Fix `arcanus edit` to report error if `EDITOR` environment variable is not
  defined instead of crashing
* Fix `arcanus unlock` to report better error message if running in a
  repository that does not contain a chest

## 0.10.1

* Fix regression in `arcanus setup` so it works in a new repo

## 0.10.0

* Don't require `.git` directory to exist

## 0.9.0

* Pretty print hash in show command if key is a nested hash
* Don't delete `ARCANUS_PASSWORD` environment variable after unlocking key
* Add `diff` command to show what was changed in the chest

## 0.8.0

* Add back ability to access chest keys via method calls

## 0.7.0

* Add `to_hash` and `to_yaml` methods to `Arcanus::Chest`

## 0.6.0

* Remove ability to access chest keys via method calls

## 0.5.0

* Fix bug where Arcanus API wouldn't work in repo with unlocked key
* Define `respond_to?` methods for `Chest`/`Chest::Item` classes

## 0.4.0

* Ensure temporary file edited during `arcanus edit` ends with `.yaml` so
  editor chooses correct syntax highlighter
* Fix password setting to not include trailing newline
* Allow key to be unlocked via environment variable in API

## 0.3.0

* Add support for accessing items in chest using method calls
* Include comment in `chest.yaml` warning user not to edit directly

## 0.2.0

* Improve `show` command to display individual keys via optional key path
  argument
* Improve `edit` command to modify individual keys via optional key path/value
  arguments
* Fix setting of values within nested hashes
* Change location of all Arcanus-related files to be stored in `.arcanus`
  directory (also change their name to be more descriptive)
* Add API for using Arcanus in Ruby applications

## 0.1.0

* Initial release
