
local figure_required = require "lib.figure_required"

local build_dir = arg[2] or "builds/page_html_set/page_html/"
os.execute("mkdir -p " .. build_dir)

local _, lfs = pcall(function() return require "lfs" end)
for k,v in pairs(figure_required.file(arg[1])) do
   local dir, file = unpack(v)
   local file_dir = string.match(file, "^([%w_/]+)/[%w_]+[.]lua$") or ""

   os.execute("mkdir -p " .. build_dir .. file_dir)  -- Make the directory.
   -- Move the file in there.
   os.execute("cp -u " .. dir .. file .. " " .. build_dir .. file)

   local fr_file = dir .. file_dir
   local function cp(name, is_dir)
      if lfs and not lfs.attributes(fr_file .. "/" .. name) then return end
      os.execute(string.format("cp -%su %s/%s %s",
                               (is_dir and "r") or "", fr_file, name, build_dir .. file_dir))
   end
   cp("assets/", true)
   for _, name in
      ipairs{"readme.md", "README", "README.md", "LICENSE", "COPYING", "README"}
   do
      cp(name)
   end

   if lfs and lfs.attributes(build_dir .. file_dir) then
      os.execute("TODIR=" .. build_dir .. file_dir .. "; cd " .. fr_file .. [[;
if git remote -v >> /dev/null; then
TOFILE=$OLDPWD/$TODIR/git_info;
echo '#' Note, this file has no particular purpose, top links might be useful for > $TOFILE
echo '#' finding the origin of the file >> $TOFILE
git remote -v >> $TOFILE;
echo >> $TOFILE;
git log -n 1 . >> $TOFILE;
fi]])
   end
end
