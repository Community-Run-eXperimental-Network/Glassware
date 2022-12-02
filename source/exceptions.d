module source.exceptions;

import std.conv : to;

public enum GlasswareError
{
    GETREGROUTES_PARSE_ERROR
}

public final class GlasswareException : Exception
{
    private GlasswareError errType;

    this(GlasswareError errType)
    {
        super("Glassware error occurred: "~to!(string)(errType));

        this.errType = errType;
    }

    public GlasswareError getError()
    {
        return errType;
    }
}