module source.exceptions;

import std.conv : to;

// NOTE: Do not change the order of these please, only append
public enum GlasswareError
{
    NETWORK_ERROR,
    JSON_PARSING_ERROR
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