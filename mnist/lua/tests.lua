local autograd = require("autograd")
local matrix = require("matrix")
local nn = require("nn")

local function expect(expected, actual, msg)
  local message = msg .. "\n"
  message = message .. string.format("Expected %s, got %s", tostring(expected), tostring(actual))
  assert(expected == actual, message)
end

local function test_relu()
  local x1 = autograd.Value:new(5)
  local y1 = x1:relu()

  local x2 = autograd.Value:new(-2)
  local y2 = x2:relu()

  expect(0, x1.grad, "gradient before backward pass")

  y1:backward()
  y2:backward()

  expect(5, y1.data, "relu(5)")
  expect(0, y2.data, "relu(-2)")
  expect(1, x1.grad, "grad(relu(5)) wrt input")
  expect(0, x2.grad, "grad(relu(-2)) wrt input")

  -- grad of output wrt itself is always 1
  expect(1, y1.grad, "grad(relu(5)) wrt output")
  expect(1, y2.grad, "grad(relu(5)) wrt output")
end

test_relu()

local function test_add()
  local x1 = autograd.Value:new(5)
  local x2 = autograd.Value:new(2)

  local y = x1 + x2
  y:backward()

  expect(7, y.data, "5+2")
  expect(1, x1.grad, "grad(5+2) wrt first arg")
  expect(1, x2.grad, "grad(5+2) wrt second arg")
  expect(1, y.grad, "grad(5+2) wrt output")
end

test_add()

local function test_mul()
  local x1 = autograd.Value:new(4)
  local x2 = autograd.Value:new(3)

  local y = x1 * x2
  y:backward()

  expect(12, y.data, "4*3")
  expect(3, x1.grad, "grad(4*3) wrt first arg")
  expect(4, x2.grad, "grad(4*3) wrt second arg")
  expect(1, y.grad, "grad(4*3) wrt output")
end

test_mul()

local function test_matrix_equality()
  local x = matrix.Matrix:new({ { 1, 2 }, { 3, 4 } })
  local y = matrix.Matrix:new({ { 1, 2 }, { 3, 4 } })
  local z = matrix.Matrix:new({ { 1, 2 } })

  expect(true, x == y, "matrix equality")
  expect(true, x ~= z, "matrix inequality")
end

test_matrix_equality()

local function test_matrix_transpose()
  local x = matrix.Matrix:new({ { 1, 2 }, { 3, 4 }, { 5, 6 } })

  expect(3, x.shape[1], "shape of first dimension")
  expect(2, x.shape[2], "shape of second dimension")
  expect(2, x:getitem({ 1, 2 }), "element at index (1,2)")
  expect(5, x:getitem({ 3, 1 }), "element at index (3,1)")

  x:transpose()

  expect(2, x.shape[1], "shape of first dimension")
  expect(3, x.shape[2], "shape of second dimension")
  expect(2, x:getitem({ 2, 1 }), "element at index (2,1)")
  expect(5, x:getitem({ 1, 3 }), "element at index (1,3)")
end

test_matrix_transpose()

local function test_matrix_addition()
  local x = matrix.Matrix:new({ { 1, 2 } })
  local y = matrix.Matrix:new({ { 3, 4 } })
  local z = matrix.Matrix:new({ { 4, 6 } })

  expect(z, x + y, "matrix addition")
end

test_matrix_addition()

local function test_matrix_multiplication()
  local x = matrix.Matrix:new({ { 1, 2 } })
  local y = matrix.Matrix:new({ { 3, 4 }, { 5, 6 } })

  local a = matrix.Matrix:new({ { 13, 16 } })
  local b = matrix.Matrix:new({ { 11 }, { 17 } })

  expect(a, x * y, "matmul x@y")

  x:transpose()

  expect(b, y * x, "matmul y@x^T")
end

test_matrix_multiplication()