import std.stdio;

import vibe.d;
import std.json;
import std.string;
import std.net.curl;
import std.base64;

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
	jsonParsed = parseJSON(get(edbBaseURL~"contents"));  // TODO: Handle CurlException

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

	jsonParsed = parseJSON(get(edbBaseURL~"contents"));  // TODO: Handle CurlException

	return jsonParsed;
}

public final class Person
{
	private JSONValue personBlock;
	protected string name, email, gpgKey;

	private this() {}

	/** 
	 * Provided the person block as JSON this will attempt
	 * to parse it, if so returning a <code>Person</code> object. If a
	 * failure occurs during parsing then <code>null</code>
	 * is returned
	 *
	 * Params:
	 *   personBlock = The JSON-encoded person block
	 * Returns: The Person object representing such information
	 */
	public static Person getPerson(JSONValue personBlock)
	{
		try
		{
			Person person = new Person();

			person.name = personBlock["name"].str();
			person.email = personBlock["email"].str();
			person.gpgKey = personBlock["gpg"].str();

			return person;
		}
		catch(JSONException e)
		{
			return null;
		}
	}
}

public final class Network
{
	private string networkName;
	private JSONValue networkData;
	
	this(string networkName)
	{
		this.networkName = networkName;

		// Fetch the data
		initData(networkName);
	}

	private void initData(string networkName)
	{
		try
		{
			JSONValue jsonParsed;
			jsonParsed = parseJSON(get(edbBaseURL~"contents/"~networkName~".json")); // TODO: Handle CurlException

			

			// Extract the data (decode base64-encoded data)
			string base64Data = jsonParsed["content"].str();

			string contents = cast(string)Base64.decode(base64Data);
			JSONValue networkContents = parseJSON(contents);

			writeln(networkContents.toPrettyString());

			networkData = networkContents;
		}
		catch(JSONException e)
		{
			// TODO: Handle this
			writeln(e);
		}
		catch(CurlException e)
		{
			// TODO: Handle this
			writeln(e);
		}
	}

	/** 
	 * Returns the owner/contact details for this network
	 *
	 * Returns: The <code>Person</code> object representing
	 * this information, <code>null</code> if such information
	 * does not exist
	 */
	public Person getPerson()
	{
		return Person.getPerson(networkData["person"]);
	}
}

unittest
{
	writeln("Edit source/app.d to start your project.");

	// TODO: Add command-line handling here and configurtion file parsing

	
	// Fetch list of all networks
	string[] networks = fetchNetworks();

	import std.algorithm;
	assert(equal(networks, ["bandura", "deavmi", "reddawn", "skiqqy", "ty3r0x"]));


	writeln("Found networks: "~to!(string)(networks));

	foreach(string network; networks)
	{
		Network networkFetched = new Network(network);
		writeln(networkFetched);
		writeln("Person info (if any): ", networkFetched.getPerson());
	}
}

void main(string[] args)
{
	

	// Start the web server
	runApplication();
}
