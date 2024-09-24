-- thx raltyro for giving me this <3
local Native = {}

local ffi = require("ffi")

local comdlg32 = ffi.load("comdlg32")
local dwmapi = ffi.load("dwmapi")

local kernel32 = ffi.load("kernel32")

ffi.cdef [[\
	typedef void* HWND;
	typedef const char* LPCSTR;
	typedef char* LPSTR;
	typedef int BOOL;
	typedef unsigned int DWORD;
	typedef void* HINSTANCE;
	typedef unsigned short WORD;
	typedef long long LPARAM;
	typedef const void* LPCVOID;

	typedef struct {
		DWORD     lStructSize;
		HWND      hwndOwner;
		HINSTANCE hInstance;
		LPCSTR    lpstrFilter;
		LPSTR     lpstrCustomFilter;
		DWORD     nMaxCustFilter;
		DWORD     nFilterIndex;
		LPSTR     lpstrFile;
		DWORD     nMaxFile;
		LPSTR     lpstrFileTitle;
		DWORD     nMaxFileTitle;
		LPCSTR    lpstrInitialDir;
		LPCSTR    lpstrTitle;
		DWORD     Flags;
		WORD      nFileOffset;
		WORD      nFileExtension;
		LPCSTR    lpstrDefExt;
		LPARAM    lCustData;
		LPCVOID   lpfnHook;
		LPCSTR    lpTemplateName;
		void*     pvReserved;
		DWORD     dwReserved;
		DWORD     FlagsEx;
	} WINDOWDIALOGUE;

	BOOL GetSaveFileNameA(WINDOWDIALOGUE *lpofn);
	BOOL GetOpenFileNameA(WINDOWDIALOGUE *lpofn);


	typedef int BOOL;
	typedef long LONG;
	typedef uint32_t UINT;
	typedef int HRESULT;
	typedef unsigned int DWORD;
	typedef const void* PVOID;
	typedef const void* LPCVOID;
	typedef const char* LPCSTR;
	typedef DWORD HMENU;
	typedef struct HWND HWND;
	typedef void* HANDLE;
    typedef HANDLE HCURSOR;

	typedef struct tagRECT {
		union{
			struct{
				LONG left;
				LONG top;
				LONG right;
				LONG bottom;
			};
			struct{
				LONG x1;
				LONG y1;
				LONG x2;
				LONG y2;
			};
			struct{
				LONG x;
				LONG y;
			};
		};
	} RECT, *PRECT,  *NPRECT,  *LPRECT;

	HWND FindWindowA(LPCSTR lpClassName, LPCSTR lpWindowName);
	HWND FindWindowExA(HWND hwndParent, HWND hwndChildAfter, LPCSTR lpszClass, LPCSTR lpszWindow);
	HWND GetActiveWindow(void);
	LONG SetWindowLongA(HWND hWnd, int nIndex, LONG dwNewLong);
	BOOL ShowWindow(HWND hWnd, int nCmdShow);
	BOOL UpdateWindow(HWND hWnd);

	HRESULT DwmGetWindowAttribute(HWND hwnd, DWORD dwAttribute, PVOID pvAttribute, DWORD cbAttribute);
	HRESULT DwmSetWindowAttribute(HWND hwnd, DWORD dwAttribute, LPCVOID pvAttribute, DWORD cbAttribute);
	HRESULT DwmFlush();

	HCURSOR LoadCursorA(HANDLE hInstance, const char* lpCursorName);
    HCURSOR SetCursor(HCURSOR hCursor);

	HANDLE GetStdHandle(DWORD nStdHandle);
	BOOL SetConsoleTextAttribute(HANDLE hConsoleOutput, WORD wAttributes);
]]

--local Rect = ffi.metatype("RECT", {})
local function toInt(v) return v and 1 or 0 end

local function getWindowHandle(title)
	local window = ffi.C.FindWindowA(nil, title)
	if window == nil then
		window = ffi.C.GetActiveWindow()
		window = ffi.C.FindWindowExA(window, nil, nil, title)
	end
	return window
end
local function getActiveWindow() return ffi.C.GetActiveWindow() or getWindowHandle(love.window.getTitle()) end

local function openDialogue(title, fileTypes, initialFile)
	local ofn = ffi.new("WINDOWDIALOGUE")
	ofn.lStructSize = ffi.sizeof("WINDOWDIALOGUE")

	if not fileTypes then 
		ofn.lpstrFilter = "All Files\0*.*"
	else
		local filters = ""
		for _, type in ipairs(fileTypes) do filters = filters .. type[1] .. "\0" .. type[2] .. "\0" end
		ofn.lpstrFilter = filters
	end

	ofn.lpstrFile, ofn.nMaxFile = initialFile and ffi.new("char[260]", initialFile) or ffi.new("char[260]"), 260
	ofn.lpstrFileTitle, ofn.nMaxFileTitle = ffi.new("char[260]"), 260
	ofn.lpstrTitle = title
	ofn.Flags = 0x00000002

	return ofn
end

Native.default_cursor_type = "ARROW"
Native.cursor_type = {
	ARROW = 32512,
	IBEAM = 32513,
	WAIT = 32514,
	CROSS = 32515,
	UPARROW = 32516,
	SIZENWSE = 32642,
	SIZENESW = 32643,
	SIZEWE = 32644,
	SIZENS = 32645,
	SIZEALL = 32646,
	NO = 32648,
	HAND = 32649,
	APPSTARTING = 32650,
	HELP = 32651,
	PIN = 32671,
	PERSON = 32672
}
Native.console_color = {
	black = 0,
	dark_blue = 1,
	dark_green = 2,
	dark_cyan = 3,
	dark_red = 4,
	dark_magenta = 5,
	dark_yellow = 6,
	light_gray = 7,
	gray = 8,
	blue = 9,
	green = 10,
	cyan = 11,
	red = 12,
	magenta = 13,
	yellow = 14,
	white = 15,
	none = -1
}
Native.STD_INPUT_HANDLE = ffi.cast("DWORD", -10)
Native.STD_OUTPUT_HANDLE = ffi.cast("DWORD", -11)
Native.STD_ERROR_HANDLE = ffi.cast("DWORD", -12)
Native.INVALID_HANDLE_VALUE = ffi.cast("HANDLE", -1)

function Native.ask_open_file(title, file_types)
	local dialogue = openDialogue(title or "Open File", file_types)
	if comdlg32.GetOpenFileNameA(dialogue) == 1 then return ffi.string(dialogue.lpstrFile) end
end

function Native.ask_save_as_file(title, file_types, initial_file)
	local dialogue = openDialogue(title or "Save As", file_types, "")
	if comdlg32.GetSaveFileNameA(dialogue) == 1 then return ffi.string(dialogue.lpstrFile) end
end

function Native.set_cursor(type)
	local cursor_type = Native.cursor_type[type:upper()]
	if cursor_type then
		ffi.C.SetCursor(ffi.C.LoadCursorA(nil, ffi.cast("const char*", cursor_type)))
	end
end

function Native.set_dark_mode(enable)
	local window = getActiveWindow()
	local darkMode = ffi.new("int[1]", toInt(enable))

	if dwmapi.DwmSetWindowAttribute(window, 19, darkMode, 4) ~= 0 then
		dwmapi.DwmSetWindowAttribute(window, 20, darkMode, 4)
	end
end

function Native.set_console_colors(fg_color, bg_color)
	if fg_color == nil or fg_color == Native.console_color.none then
		fg_color = Native.console_color.light_gray
	end
	if bg_color == nil or bg_color == Native.console_color.none then
		bg_color = Native.console_color.black
	end
	local console = ffi.C.GetStdHandle(Native.STD_OUTPUT_HANDLE)
	ffi.C.SetConsoleTextAttribute(console, (bg_color * 16) + fg_color)
end

return Native