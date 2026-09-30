---
name: windows-interop
description: Interop nativo Windows em C#/.NET — P/Invoke (LibraryImport/DllImport), CsWin32, COM (GeneratedComInterface), SafeHandle, marshaling de structs, buffers não gerenciados, NTSTATUS/HRESULT, tradução de headers C/C++ e compatibilidade com NativeAOT/trimming. Use ao escrever, revisar ou depurar código que chama kernel32, ntdll, advapi32, user32, ole32 e afins.
---

# Interop nativo Windows em C#

Objetivo: código de interop **seguro, idiomático, AOT/trim-safe e auditável**, não wrappers crus de P/Invoke. Exemplos de código em [reference.md](reference.md).

## Antes de escrever código

1. Leia o `.csproj` do projeto: `TargetFramework`, `PublishAot`, `IsTrimmable`, `AllowUnsafeBlocks`, se já existe `Microsoft.Windows.CsWin32` e se há `DisableRuntimeMarshalling`. Siga as convenções de interop que o projeto já usa.
2. Identifique a API nativa exata e confira a assinatura em learn.microsoft.com ou no header do SDK. Assinatura errada raramente falha na primeira chamada: costuma corromper a pilha só em x86 ou em produção.
3. Quando houver mais de um caminho razoável (tabela abaixo), apresente o trade-off e **pergunte** antes de seguir. Não imponha CsWin32.

## Escolha do caminho

| Situação | Caminho |
| --- | --- |
| .NET 7+ e poucas chamadas ou controle total desejado | `[LibraryImport]` manual (padrão) |
| .NET Framework, .NET Standard ou .NET ≤ 6 | `[DllImport]` manual |
| Superfície Win32 grande e dependência de source generator aceitável (qualquer target, inclusive .NET Framework) | Sugerir **CsWin32** |
| COM em .NET 8+ | `[GeneratedComInterface]` / `[GeneratedComClass]` |
| COM em target anterior | `[ComImport]` manual, com cautela |
| NativeAOT / trimmed | Somente marshaling gerado em compile-time (`LibraryImport`, `GeneratedComInterface`, CsWin32 com `allowMarshaling: false` ou APIs blittable). `DllImport` só com assinaturas blittable. |

## Regras não negociáveis

1. **Nenhum handle do SO como `IntPtr`/`nint` cru.** Use o `SafeHandle` do BCL (`SafeFileHandle`, `SafeProcessHandle`, `SafeWaitHandle`, `SafeAccessTokenHandle`, `SafeRegistryHandle`…) ou escreva um: `sealed`, construtor sem parâmetros, `ReleaseHandle` que retorna `bool` e nunca lança exceção. Base: `SafeHandleZeroOrMinusOneIsInvalid` na maioria dos casos, `SafeHandleMinusOneIsInvalid` quando 0 é um valor válido.
2. **API pública gerenciada e idiomática.** Exponha interfaces, `record`s, `Stream`, `Span<T>`, enums `[Flags]` com tipo base explícito. P/Invokes, structs Win32 e constantes ficam `internal` em classes por DLL (`Interop.Kernel32`, `Interop.Advapi32`), um arquivo por DLL quando a superfície crescer.
3. **Tudo que vem do nativo é não confiável.** Cheque o código de erro antes de usar o buffer. Valide tamanhos e offsets retornados contra o tamanho realmente alocado. Buffers de saída são `Span<T>` de tamanho conhecido.
4. **Cleanup determinístico.** `using` sempre. Sem finalizadores em wrappers: o `SafeHandle` cuida disso.
5. **Declare a origem.** Comentário com o link da documentação ou a assinatura C original acima de cada P/Invoke. Constantes com o nome do SDK (`GENERIC_READ`, `ERROR_INSUFFICIENT_BUFFER`).

## LibraryImport (.NET 7+)

- Classe e método `static partial`.
- `StringMarshalling = StringMarshalling.Utf16` para APIs `W` (não existe ANSI; use `Utf8` ou marshaller customizado se a API exigir `char*` de 1 byte). Use `EntryPoint` com o sufixo `W` explícito.
- **`bool` não tem marshaling padrão**: é erro de compilação sem `[MarshalAs(UnmanagedType.Bool)]` (Win32 `BOOL`, 4 bytes) ou `[MarshalAs(UnmanagedType.U1)]` (`BOOLEAN`, 1 byte). Vale para parâmetros, retorno e campos de struct marshaled. Alternativa: declarar como `int`/`byte`.
- `string` também exige `StringMarshalling` ou `[MarshalUsing]`.
- Tipos não blittable exigem `[MarshalUsing]`/`[NativeMarshalling]` com marshaller customizado; não há marshalling IL em runtime.
- Não é preciso `[UnmanagedCallConv]` para APIs Win32 (x64 e ARM64 têm uma única convenção; em x86 o padrão já é `stdcall`). Use só para `cdecl` (ex.: CRT) ou convenções especiais.
- Retorno `SafeHandle` é suportado diretamente.
- Considere `[assembly: DisableRuntimeMarshalling]` em projetos só com assinaturas blittable: garante em compile-time que nada depende de marshalling em runtime.

## DllImport (targets antigos)

- `CharSet = CharSet.Unicode` sempre que a API tem versão `W`. **O padrão do C# é `Ansi`**, então sem isso strings viram ANSI silenciosamente.
- `ExactSpelling = true` com `EntryPoint` terminando em `W`: evita a busca por variantes A/W e deixa explícito o que é chamado.
- `SetLastError = true` quando a documentação manda usar `GetLastError`.
- `CallingConvention` só quando diferir do padrão (`Winapi`, que é `StdCall` em Windows x86), por exemplo `Cdecl` para CRT e funções varargs.
- `bool` aqui é marshaled como `BOOL` (4 bytes) por padrão; `BOOLEAN` precisa de `[MarshalAs(UnmanagedType.U1)]`.
- Retorne `SafeHandle`, não `IntPtr`.

## Mapeamento de tipos e pegadinhas

- `LONG`/`DWORD`/`ULONG` → `int`/`uint` (sempre 32 bits no Windows). `LONGLONG`/`LARGE_INTEGER` → `long`. `SIZE_T`/`ULONG_PTR`/`LONG_PTR`/ponteiros → `nuint`/`nint`. C# `long` **não** é `LONG`.
- `CHAR` → `byte`; `WCHAR` → `char`. Nunca `char` para campos ANSI.
- Leia `Marshal.GetLastPInvokeError()` (.NET 6+) **imediatamente** após a chamada que falhou. Em .NET Framework, `Marshal.GetLastWin32Error()`.
- Delegates passados ao nativo: para callbacks síncronos, mantenha o delegate em variável local e chame `GC.KeepAlive` após a chamada. Para callbacks assíncronos ou registrados, mantenha a referência em campo pelo tempo de vida do registro (ou use `GCHandle`). Em .NET 5+, prefira ponteiros de função `delegate* unmanaged` com métodos `[UnmanagedCallersOnly]`, que não têm esse problema.
- `GC.KeepAlive` é correto em chamadas síncronas que usam um recurso sem `SafeHandle` (ex.: `this` com handle cru, delegates). Se aparece para proteger um handle do SO, falta um `SafeHandle`.
- x86 vs x64: campos de ponteiro ou `SIZE_T` declarados como `int`/`long` quebram em uma das arquiteturas. Cuidado também com WOW64 (redirecionamento de registro e de `System32`).

## Structs

- `[StructLayout(LayoutKind.Sequential)]` explícito; `LayoutKind.Explicit` + `[FieldOffset]` para uniões, nunca sobrepondo referências gerenciadas.
- Prefira structs **blittable**: são fixadas em vez de copiadas e funcionam sem marshalling em runtime.
- Arrays e strings inline: `[InlineArray(N)]` (.NET 8+) ou buffer `fixed`; `ByValTStr`/`ByValArray` só com marshalling em runtime (`DllImport`).
- Valide o tamanho contra o documentado para x86 e x64: **`Marshal.SizeOf<T>()`** dá o tamanho nativo (o que importa para a API). `Unsafe.SizeOf<T>()` dá o tamanho gerenciado e só coincide para structs blittable.

## Buffers

- Pequenos e fixos: `stackalloc` em `Span<T>`, até ~1 KB.
- Dinâmicos: `ArrayPool<T>.Shared` com `Return` em `finally`; `NativeMemory.Alloc`/`Free` quando a API exige memória que não se move depois da chamada (I/O assíncrono, `OVERLAPPED`).
- Padrão "consulta tamanho, depois dados" (`ERROR_INSUFFICIENT_BUFFER`, `ERROR_MORE_DATA`, `STATUS_INFO_LENGTH_MISMATCH`): use o tamanho retornado quando existir, cresça em loop (o tamanho pode mudar entre chamadas) e imponha um teto.

## Erros

- Win32: `throw new Win32Exception(error)` ou exceção tipada (`IOException`, `UnauthorizedAccessException`, `FileNotFoundException`) na fronteira pública.
- HRESULT: trate os esperados (`S_FALSE`…) antes de `Marshal.ThrowExceptionForHR`.
- NTSTATUS: sucesso é `status >= 0` (`NT_SUCCESS`). Valores de *warning* (`0x8…`, ex.: `STATUS_BUFFER_OVERFLOW`) são negativos, mas podem trazer dados parciais: trate-os explicitamente. Use `RtlNtStatusToDosError` para mapear para Win32.
- API pública não retorna `bool` de sucesso sem contexto: exceção tipada ou tipo de resultado explícito.

## COM moderno (.NET 8+)

- `[GeneratedComInterface]` + `[Guid]` em interface `partial`; `StringMarshalling` na interface se houver strings; ordem dos métodos idêntica à vtable (herde da interface base gerada em vez de repetir métodos).
- Sem `[ComImport]` nem `Marshal.GetObjectForIUnknown` em código novo; use `StrategyBasedComWrappers`.
- Sinalize requisitos de apartment (STA/MTA) e thread affinity.

## CsWin32 (quando o usuário aceitar)

- `PackageReference` para `Microsoft.Windows.CsWin32` com `PrivateAssets="all"`.
- `NativeMethods.txt` com apenas as funções, constantes e tipos necessários (não módulos inteiros).
- `NativeMethods.json`: `"allowMarshaling": false` para gerar só assinaturas blittable (útil para AOT/`DisableRuntimeMarshalling`); `"public"` fica `false` (padrão) para manter tudo interno.
- As regras de SafeHandle, erros, buffers e API pública continuam valendo: CsWin32 gera a camada baixa; a camada gerenciada é responsabilidade sua.

## Formato da resposta

- 2 a 4 linhas explicando o caminho escolhido e por quê.
- Código completo e compilável: constantes, enums, structs, SafeHandles, P/Invokes e API pública.
- Comentários só no não óbvio: alinhamento, motivo de um `[MarshalAs]`, bitness, ordem de liberação entre handles.
- Declare explicitamente: "AOT/trim-safe" ou "depende de marshalling em runtime; não funciona com `DisableRuntimeMarshalling`/NativeAOT sem ajustes".
- Aponte riscos: x86/x64, WOW64, STA/MTA, reentrância, permissões/UAC.
- Não troque `SafeHandle` por `IntPtr` "por performance" sem benchmark que justifique.
