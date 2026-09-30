# Exemplos de referência

## LibraryImport (.NET 7+)

```csharp
internal static partial class Interop
{
    internal static partial class Kernel32
    {
        // HANDLE CreateFileW(LPCWSTR, DWORD, DWORD, LPSECURITY_ATTRIBUTES, DWORD, DWORD, HANDLE);
        // https://learn.microsoft.com/windows/win32/api/fileapi/nf-fileapi-createfilew
        [LibraryImport("kernel32.dll", EntryPoint = "CreateFileW", SetLastError = true,
                       StringMarshalling = StringMarshalling.Utf16)]
        internal static partial SafeFileHandle CreateFile(
            string lpFileName,
            uint dwDesiredAccess,
            FileShare dwShareMode,
            nint lpSecurityAttributes,
            FileMode dwCreationDisposition,
            uint dwFlagsAndAttributes,
            nint hTemplateFile);

        // BOOL obriga [MarshalAs] em LibraryImport.
        [LibraryImport("kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        internal static partial bool GetFileSizeEx(SafeFileHandle hFile, out long lpFileSize);
    }
}
```

## DllImport (.NET Framework / .NET Standard)

```csharp
internal static class Kernel32
{
    [DllImport("kernel32.dll", EntryPoint = "CreateFileW", SetLastError = true,
               CharSet = CharSet.Unicode, ExactSpelling = true)]
    internal static extern SafeFileHandle CreateFile(
        string lpFileName,
        uint dwDesiredAccess,
        FileShare dwShareMode,
        IntPtr lpSecurityAttributes,
        FileMode dwCreationDisposition,
        uint dwFlagsAndAttributes,
        IntPtr hTemplateFile);
}
```

## SafeHandle customizado

```csharp
internal sealed class SafeRegistryKeyHandle : SafeHandleZeroOrMinusOneIsInvalid
{
    public SafeRegistryKeyHandle() : base(ownsHandle: true) { }

    protected override bool ReleaseHandle() =>
        Interop.Advapi32.RegCloseKey(handle) == 0; // ERROR_SUCCESS
}
```

## Buffer crescente com NTSTATUS

```csharp
const int STATUS_INFO_LENGTH_MISMATCH = unchecked((int)0xC0000004);
const int MaxBufferSize = 64 * 1024 * 1024;

int size = 256 * 1024;
while (true)
{
    byte[] buffer = ArrayPool<byte>.Shared.Rent(size);
    try
    {
        int status = Interop.NtDll.NtQuerySystemInformation(
            SystemProcessInformation, buffer, buffer.Length, out int needed);

        if (status == STATUS_INFO_LENGTH_MISMATCH)
        {
            // A lista pode crescer entre chamadas: margem sobre o tamanho retornado.
            size = Math.Max(needed + 64 * 1024, buffer.Length * 2);
            if (size > MaxBufferSize)
                throw new InvalidOperationException("Buffer excedeu o limite.");
            continue;
        }

        if (status < 0)
            throw new Win32Exception(Interop.NtDll.RtlNtStatusToDosError(status));

        // needed/offsets vindos do nativo: validar contra buffer.Length antes de ler.
        return Parse(buffer.AsSpan(0, Math.Min(needed, buffer.Length)));
    }
    finally
    {
        ArrayPool<byte>.Shared.Return(buffer);
    }
}
```

## Callback com ponteiro de função (.NET 5+)

```csharp
internal static unsafe partial class User32
{
    [LibraryImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    internal static partial bool EnumWindows(delegate* unmanaged<nint, nint, int> lpEnumFunc, nint lParam);
}

[UnmanagedCallersOnly]
private static int EnumWindowsCallback(nint hwnd, nint lParam)
{
    var list = (List<nint>)GCHandle.FromIntPtr(lParam).Target!;
    list.Add(hwnd);
    return 1; // TRUE: continuar
}

internal static unsafe List<nint> GetTopLevelWindows()
{
    var list = new List<nint>();
    GCHandle gch = GCHandle.Alloc(list);
    try
    {
        Interop.User32.EnumWindows(&EnumWindowsCallback, GCHandle.ToIntPtr(gch));
    }
    finally
    {
        gch.Free();
    }
    return list;
}
```

## COM gerado (.NET 8+)

```csharp
[GeneratedComInterface]
[Guid("xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")]
internal partial interface IMyComInterface
{
    // Ordem idêntica à vtable, após os métodos de IUnknown.
    void DoWork(int value);
}
```
