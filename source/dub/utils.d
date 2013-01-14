/**
	...
	
	Copyright: © 2012 Matthias Dondorff
	License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
	Authors: Matthias Dondorff
*/
module dub.utils;

import vibe.core.file;
import vibe.core.log;
import vibe.data.json;
import vibe.inet.url;
import vibe.stream.operations;
import vibe.utils.string;

// todo: cleanup imports.
import std.array;
import std.file;
import std.exception;
import std.algorithm;
import std.zip;
import std.typecons;
import std.conv;


package bool isEmptyDir(Path p) {
	foreach(DirEntry e; dirEntries(to!string(p), SpanMode.shallow))
		return false;
	return true;
}

package Json jsonFromFile(Path file, bool silent_fail = false) {
	if( silent_fail && !existsFile(file) ) return Json.EmptyObject;
	auto f = openFile(to!string(file), FileMode.Read);
	scope(exit) f.close();
	auto text = stripUTF8Bom(cast(string)f.readAll());
	return parseJson(text);
}

package Json jsonFromZip(string zip, string filename) {
	auto f = openFile(zip, FileMode.Read);
	ubyte[] b = new ubyte[cast(uint)f.leastSize];
	f.read(b);
	f.close();
	auto archive = new ZipArchive(b);
	auto text = stripUTF8Bom(cast(string)archive.expand(archive.directory[filename]));
	return parseJson(text);
}

package void writeJsonFile(Path path, Json json)
{
	auto f = openFile(path, FileMode.CreateTrunc);
	scope(exit) f.close();
	toPrettyJson(f, json);
}

package bool isPathFromZip(string p) {
	enforce(p.length > 0);
	return p[$-1] == '/';
}

package bool existsDirectory(Path path) {
	if( !existsFile(path) ) return false;
	auto fi = getFileInfo(path);
	return fi.isDirectory;
}