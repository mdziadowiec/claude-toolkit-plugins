---
name: error-messages
description: Rules for writing and reviewing the text of error messages — exception messages, validation errors, CLI stderr output, API error responses, log error entries, and UI error dialogs — based on Google's "Writing Helpful Error Messages" course. Every message should say what went wrong (cause, offending value, violated limit) and how to fix it (action, example), concisely, in the reader's terms, with a neutral tone. Apply automatically whenever writing code that throws, returns, or displays an error string (`throw new ...Exception("...")`, `raise ValueError(...)`, `Write-Error`, `return BadRequest(...)`, a `MessageBox` error, a validation attribute's `ErrorMessage`), and whenever asked to write, improve, rewrite, or review error messages, even if the person only says "this message is useless" or "make this exception clearer." Do NOT trigger for diagnosing, debugging, or fixing an error the user hit (a stack trace, a failing build, a crash) — that is about the cause, not the wording.
---

# Writing Helpful Error Messages

A good error message answers two questions, as clearly and briefly as possible:

1. **What went wrong?**
2. **How does the user fix it?**

A message that answers only the first leaves the user stuck. A message that answers neither ("Error.", "Invalid input.", "Something went wrong") sends them to support or to the source code. Most bad messages are vague, imprecise, unactionable, or written for the wrong reader; the rules below address each failure.

The rules apply to every surface where an error reaches a person: exception messages, validation text, CLI output, API error bodies, log entries, and UI dialogs. Not every rule fits every audience. Aim each message at the people who will actually read it.

Source: adapted from [Writing Helpful Error Messages](https://developers.google.com/tech-writing/error-messages), Google for Developers, licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Examples are shortened or adapted.

---

## 1. Handle errors before you word them

The best wording can't help if the error never surfaces or loses its cause on the way out.

- **Don't fail silently.** If something goes wrong, the user (and whoever supports them) needs to know. Users will make mistakes and misuse the system in ways you can't fully prevent, so plan error messages during design, not after the first bug report.
- **Follow the error conventions of your language and framework.** Use the idiomatic exception types, result types, or status objects rather than inventing a parallel scheme. For APIs, return a standard status code and a structured error body (for example RFC 9457 `application/problem+json`, or Google's AIP-193 error model).
- **Don't swallow the root cause.** A generic "Server error" can hide a crashed service, a dropped network connection, a permissions problem, or a state mismatch. Each of these needs a different fix. When you catch and rethrow, keep the original exception as the inner exception or cause, and add context about the specific failure.
- **Raise errors as early as useful.** An error raised far from where it happened is expensive to debug, because the context that explains it is gone.
- **Use error codes, and document them.** A stable numeric or symbolic code next to the text helps support staff search logs and catalogs. This applies to internal and external errors alike.

## 2. Explain the problem

### Identify the cause

Say exactly what went wrong. "Something is wrong with X" is not a cause.

| Not recommended | Recommended |
|---|---|
| Bad directory. | The `logs` directory exists but is not writable. To add files to this directory, make it writable: [how]. |
| Invalid field 'picture'. | The 'picture' field can appear only once on the command line; this command line contains it 3 times. |

If the rule changed between versions, say so: users often hit errors because something that used to work no longer does.

### Show the offending value

If the user entered or controls the value that caused the error (text, a setting, a command-line argument, a file), put that value in the message. Seeing their own input next to the rule lets them spot the mismatch without guessing which field was wrong.

| Not recommended | Recommended |
|---|---|
| Invalid postal code. | A US postal code has 5 or 9 digits. The postal code you specified (4872953) has 7 digits. |
| The specified bid is too low. | The specified bid ($5) is below the minimum bid ($8). |
| Funds can only be transferred to an account in the same country. | You can transfer funds only to an account in the same country. The sender's account is in the UK; the recipient's account is in Canada. |

If the offending value is very long (a multi-line payload, a large path list), truncate it to the essential part or disclose it progressively (see section 4).

### State the requirement or limit

Don't assume the user knows your system's constraints. Name the limit, and the actual value that broke it.

| Not recommended | Recommended |
|---|---|
| The combined size of the attachments is too big. | The combined size of the attachments (14 MB) exceeds the limit (10 MB). [How to reduce it.] |
| Permission denied. | Permission denied. Only members of the `release-managers` group can publish. [How to request membership.] |
| Time-out period exceeded. | The request timed out after 30 seconds. [What to try next.] |

The pattern: **actual value + required value + what to do about it.**

## 3. Explain the fix

### Make it actionable

After the cause, tell the user what to do. If there are several valid fixes, list them.

| Not recommended | Recommended |
|---|---|
| The client app on your device is no longer supported. | The client app on your device is no longer supported. To update it, click **Update app**. |
| Could not fetch resource: Quota 'CPUS' exceeded. Limit: 1.0 in region us-central1. | You requested 2.0 CPUs, which exceeds your quota of 1.0 CPUs in us-central1. To fix this, do one of the following: <br>• Increase your CPU quota in us-central1. <br>• Send the request to a region with more CPU quota. <br>See [link] for details. |

### Show an example of valid input

An explanation of the rule plus one correct example is usually the fastest route to a fix. Make the example relevant to the error, and give enough context that the user can see *why* the example is valid and theirs isn't.

| Not recommended | Recommended |
|---|---|
| Invalid email address. | The email address you specified (robin) is missing an @ sign and a domain name. For example: robin@example.com. |
| Invalid input. | Enter the path of a Windows executable file. An executable file usually ends in `.exe`. For example: `C:\Program Files\Custom Utilities\StringFinder.exe` |
| Syntax error on token "\|\|", "if" expected. | Syntax error in the `if` condition: the condition needs an outer pair of parentheses. For example: `if ((a > 10) \|\| (b == 0))` |

An example alone doesn't work either: "Invalid license plate (QB2 481). For example: MBR 918" leaves the user asking why one is valid and the other isn't. State the rule ("three uppercase letters, then three digits"), then the example.

## 4. Write clearly

### Be concise, but not cryptic

Cut words that don't carry meaning. Active voice is usually shorter and names who does what.

| Not recommended | Recommended |
|---|---|
| Unable to establish connection to the SQL database. | Can't connect to the SQL database. |
| The resource was not found and cannot be differentiated. What you selected doesn't exist in the cluster. | Resource `orders-db` isn't in cluster `prod-eu`. |
| The Froobus operation is no longer supported by the Frambus app. | The Frambus app no longer supports the Froobus operation. |
| The SiteID 1234 you have entered is invalid. | Invalid SiteID 1234. |

Stop before the message loses meaning. "Unsupported." is concise and useless: it names neither the thing nor the reason.

### Avoid double negatives and exceptions to exceptions

Two negatives force the reader to stop and work out whether they cancel. Watch for disguised negatives too: *prevent*, *forbid*, *deny*, *disallow*, *fail to*, *without*.

| Not recommended | Recommended |
|---|---|
| You cannot not invoke this flag. | You must invoke this flag. |
| The universal read permission on `config.yml` prevents the operating system from forbidding access. | The universal read permission on `config.yml` lets anyone read this file, which is a security risk. See [link] to restrict access. |
| The service account must have permissions on the image, except the Storage Object Viewer role, unless the Storage Object Admin role is available. | The service account must have one of the following roles: Storage Object Admin, Storage Object Creator. |

When a rule needs "except … unless …", list the allowed options instead.

### Write for the reader who sees the message

Use the terms your reader knows, and watch for the curse of knowledge: a term you use every day may mean nothing to them.

| Audience | Message |
|---|---|
| ML engineers | Exploding gradient problem. To fix this, consider gradient clipping. |
| Shoppers (not recommended) | A server dropped your client's request because the server farm is running at 92% CPU capacity. Retry in five minutes. |
| Shoppers (recommended) | So many people are shopping right now that we can't complete your purchase. Your cart is saved. Try again in five minutes. |

A developer-facing exception can name types, parameters, and file formats. An operator-facing UI message usually can't: "This app does not support JPG files" is fine for engineers, but a user uploading a receipt may not know what format their file is in, or what "upload" means. For a non-technical reader, explain how to recognize or produce what's needed, or hide the technical detail behind a link.

When the same failure reaches both developers and end users, write two messages: a technical one for the log or exception, and a plain one for the UI. Don't show a stack trace or an internal identifier where a user will read it.

### Use terminology consistently

Call each thing by one name, across every message in the product area. If one message says "datastore", every message says "datastore"; don't switch to "database" or "store" for variety. Variety helps prose, but in an error message it makes the user wonder whether two different things are involved.

| Not recommended | Recommended |
|---|---|
| Can't connect to cluster at 127.0.0.1:56. Check whether minikube is running. | Can't connect to minikube at 127.0.0.1:56. Check whether minikube is running. |
| The specified file ('camelia.txt') does not exist. Pick a different datastore and try again. | The specified file ('camelia.txt') does not exist. Pick a different file and try again. |

The same problem should produce the same message. If two parts of an app both detect a lost network connection, both should emit the same text, ideally from one shared constant or resource string.

### Format long messages for readability

- **Link to documentation** when the explanation would take more than a sentence or two, instead of putting a wall of text in the message: "Post contains unsafe information. Learn more at [link]."
- **Use progressive disclosure.** Show a short summary first, and let the user expand the full explanation (a "Details" section, a `--verbose` flag, an expandable panel). Users often skip long messages entirely.
- **Put the message next to the error.** For code, show the line and point at the column (`---------^ Syntax error`) rather than reporting the error after the listing. For forms, show the message next to the field.
- **Don't rely on color alone.** Many forms of color blindness exist, so avoiding red/green isn't enough. Pair color with another cue (bold, spacing, a `^^` marker under the bad characters) or use the other cue on its own.
- **Keep steps short.** Two steps can go in the message. Ten steps belong in linked documentation, especially when the fix itself hides the message (a user who removes a battery can no longer read the instructions on the screen).

### Set the right tone

- **Be positive: say how to get it right, not what the user did wrong.**
  "You didn't enter a name." → "Enter a name."
  "You entered an invalid postal code." → "Enter a valid postal code. [What makes one valid.]"
- **Don't blame the user.** Describe the state, not the person.
  "You specified a printer that's offline." → "The specified printer is offline."
  When you echo the user's value, attach it to the thing, not to the person's action: "You entered 12 seats." → "You can book 1 to 8 seats at a time. Requested: 12." or "The number of seats (12) is above the limit of 8."
- **Don't over-apologize.** Leave out "sorry" and "please" and spend the words on the problem and the fix.
  "We're sorry, a server error occurred and we're temporarily unable to load your spreadsheet. We apologize for the inconvenience. Please wait a while and try again." → "Docs can't open your spreadsheet right now. In the meantime, right-click the spreadsheet in the file list to download it."
  Cultures read apologies differently, so if your audience expects one, a single brief apology is fine; a paragraph of them is not.
- **Don't joke.** Users who hit an error are already frustrated, humor translates badly, and a joke takes space from the fix.
  "Is the server running? Better go catch it :D" → "The server is temporarily unavailable. Try again in a few minutes."
  "404 Error. Oops, that is embarrassing." → "Page not found. Check the URL, or go to the home page."

## 5. Back-end and API errors

- **Include the error code in the message text** when one exists, so technical users can look it up in an error catalog: "Error 409: You already own this bucket. Select another name."
- **Include a stable error identifier** that stays the same even when the human-readable text is reworded or translated. Engineers search logs by the identifier; if they had to search by text, every copy edit would break their queries.

```json
{
  "error": "Bad Request - the request is missing the required parameter 'collection_name'. Add the parameter and resubmit.",
  "errorId": "BR0x0071"
}
```

## 6. Applying this in code

Most error messages are written by a developer in the middle of writing a `throw`. A few habits carry most of the rules above:

- **Interpolate the real values.** Put the offending value, the limit, and the identifier of the thing involved into the string, rather than writing generic text.

  ```csharp
  // Not recommended
  throw new ArgumentException("Invalid timeout.");

  // Recommended
  throw new ArgumentOutOfRangeException(nameof(timeout),
      $"Timeout must be between 1 and 300 seconds. Specified: {timeout.TotalSeconds} s.");
  ```

- **Keep the cause chain.** Pass the caught exception as the inner exception when you wrap it, and add what *this* layer knows (which file, which record, which operation):

  ```csharp
  catch (IOException ex)
  {
      throw new ConfigLoadException($"Can't read configuration file '{path}'. Check that the file exists and that the service account can read it.", ex);
  }
  ```

- **Name parameters and fields as the caller sees them.** Use `nameof(...)` or the public option name, not an internal variable name the user has never seen.
- **Write the user-facing text in the product's UI language.** These rules apply in any language. If the codebase keeps UI strings in resource files, add the message there rather than hard-coding it, and keep developer-facing exception text separate from what the UI shows.
- **Don't log and rethrow the same error at every layer.** One well-worded message with the full cause chain is easier to read than five copies of a vague one.

---

## Review checklist

When writing or reviewing an error message, check each point. If you're reviewing someone else's message, rank the gaps by how much they'd help the reader, and propose a rewritten message rather than only listing the problems.

1. **Cause:** Does it say specifically what went wrong?
2. **Offending value:** If the user supplied the bad value, does the message show it?
3. **Limit:** Does it state the requirement or limit that was violated, with the actual value?
4. **Fix:** Does it tell the user what to do next?
5. **Example:** Where the format isn't obvious, does it show a valid example, with enough context to compare?
6. **Concise:** Are there words to cut, without making it cryptic?
7. **Affirmative:** Are there no double negatives and no exceptions to exceptions?
8. **Audience:** Will the person who actually sees this message understand every term?
9. **Consistent:** Does it use the same names as the product's other messages, and does the same problem always produce the same text?
10. **Format:** Is a long explanation moved behind a link or a "Details" section, and does nothing depend on color alone?
11. **Tone:** No blame, no "sorry" or "please", no jokes?
12. **Back end:** Is the root cause preserved, and are an error code and a stable identifier included where one exists?
