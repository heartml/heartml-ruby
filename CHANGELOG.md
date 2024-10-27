# Changelog

## [Unreleased]

## [1.0.0.beta17] — 2024-10-27

- Add `.` effect shortcut for `@textContent = .`

## [1.0.0.beta16] — 2024-10-26

- Fix rendering logic in Bridgetown 2.0 beta

## [1.0.0.beta15] — 2024-04-11

- Fix Fast Refresh crash in Bridgetown 2.0 alpha

## [1.0.0.beta14] - 2024-04-08

- Improve ViewComponent v3 compatibility

## [1.0.0.beta13] - 2024-04-08

- Add final Rails & ViewComponent config

## [1.0.0.beta12] - 2024-03-10

- Bugfix: shouldn't swallow `host-*` attributes for Ruby initializers

## [1.0.0.beta11] - 2024-03-10

- Fix behavior of boolean values (`true/false` on aria attributes, `""`/missing otherwise)

## [1.0.0.beta10] - 2024-02-27

- Add the `$attribute` directive so iso effects will work

## [1.0.0.beta9] - 2024-02-24

- Use `@attributes` by default

## [1.0.0.beta8] - 2024-02-23

- Simplify modules structure, add tag swap feature, other refactors
- Bump min Ruby version to 3.1

## [1.0.0.beta7] - 2023-09-25

- Add Railtie for Heartml component support in Rails

## [1.0.0.beta6] - 2023-09-06

- Improvements to directives syntax (use lambda argument instead of block)

## [1.0.0.beta5] - 2023-09-04

- Fix issue with ViewComponent in Rails apps
- Add fragment error handling

## [1.0.0.beta4] - 2023-08-27

- Refactor and improve Bridgetown plugin and simplify context handling for template rendering

## [1.0.0.beta3] - 2023-08-12

- Ensure attributes are processed on component node before it's rendered as component

## [1.0.0.beta2] - 2023-08-12

- Fix Bridgetown issues and process component "light DOM" children

## [1.0.0.beta1] - 2023-08-12

- Major refactor as part of the new Heartml project

## [1.0.0.alpha10] - 2023-04-04

- Update debugging features based on Nokolexbor fixes

## [1.0.0.alpha9] - 2023-04-02

- Add support for effects template syntax
- Let `camelcased` handle symbol arrays, so it works with `attr_reader`

## [1.0.0.alpha8] - 2023-03-23

- Fix bug with view context

## [1.0.0.alpha7] - 2023-03-23

- Provide original child nodes through the view context

## [1.0.0.alpha6] - 2023-03-23

- Indicate that child content in Bridgetown is HTML safe

## [1.0.0.alpha5] - 2023-03-23

- Add Bridgetown plugin support
