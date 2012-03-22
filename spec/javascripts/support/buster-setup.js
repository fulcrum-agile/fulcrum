buster.spec.expose();

// buster.spec doesn't have beforeEach or afterEach
beforeEach = before;
afterEach = after;

buster.assertions.add("isUndefined", {
  assert: function (actual) {
    return actual === undefined;
  },
  assertMessage: "Expected ${0} to be undefined",
  refuteMessage: "Expected not to be undefined",
  expectation: "toBeUndefined"
});

buster.assertions.add("hasClass", {
  assert: function (actual, className) {
    return actual.hasClass(className);
  },
  assertMessage: "Expected ${0} to have class '${1}",
  refuteMessage: "Expected ${0} not to have class '${1}'",
  expectation: "toHaveClass"
});
