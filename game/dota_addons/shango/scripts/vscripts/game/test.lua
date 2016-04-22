test = "no change"
print("con:"..test)
function test_01(keys)
	-- body
	print("test:"..test)
	test="change"
    print("test_01:"..test)
end
function test_02(keys)
	-- body
	print("test_02"..test)
end