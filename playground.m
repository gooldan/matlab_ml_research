a = PartialFunc(@Test, 1);

b = a(2,3,4);

function ret = Test(a,b,c,d)
    ret = a + b + c + d;
end