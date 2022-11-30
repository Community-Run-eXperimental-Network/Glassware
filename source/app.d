import std.stdio;

import vibe.d;
import std.json;
import std.string;
import std.net.curl;

string edbBaseURL = "https://codeberg.org/api/v1/repos/crxn/entitydb/";

/** 
 * Get the networks registered
 *
 * Returns: A <code>string[]</code> containing a list of all
 * registered networks
 */
string[] fetchNetworks()
{
	string[] networks;

	JSONValue jsonParsed;
	jsonParsed = parseJSON(get(edbBaseURL~"contents"));

	foreach(JSONValue networkBlock; jsonParsed.array())
	{
		string filename = networkBlock["name"].str();

		// It's only a network if the filename ends in `.json`
		if(endsWith(filename, ".json"))
		{
			// writeln("Found network: "~filename);
			networks ~= split(filename, ".")[0];
		}
		
	}

	return networks;
}


JSONValue fetchNetwork(string filename)
{
	JSONValue jsonParsed;

	jsonParsed = parseJSON(get(edbBaseURL~"contents"));

	return jsonParsed;
}

void main(string[] args)
{
	writeln("Edit source/app.d to start your project.");

	// TODO: Add command-line handling here and configurtion file parsing

	writeln(fetchNetwork("bruh").toPrettyString());


	writeln("Found networks: "~to!(string)(fetchNetworks()));

	// Start the web server
	// runApplication();
}
