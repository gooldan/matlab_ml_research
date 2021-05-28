function FuncToReturn = PartialFunc(Func, varargin)
    assert(size(varargin, 2) >= 1);
    
    %Func = varargin(1);
    Params = varargin;
    
    function varargout = Impl(varargin)
        [varargout{1:nargout}] = Func(Params{:}, varargin{:});
    end
    FuncToReturn = @Impl;
end