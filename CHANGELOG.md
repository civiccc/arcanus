# Arcanus Changelog

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
