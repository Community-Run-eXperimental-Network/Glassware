module source.exceptions;

import std.conv : to;
import std.json : JSONValue;

// NOTE: Do not change the order of these please, only append
public enum GlasswareError
{
    NETWORK_ERROR,
    JSON_PARSING_ERROR,
    NO_ROUTES,
    ROUTE_NOT_FOUND
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


public JSONValue makeError(GlasswareError errorCode)
{
	JSONValue errorBlock;
	errorBlock["detail"] = to!(string)(errorCode);
	errorBlock["error"] = errorCode;

	return errorBlock;
}