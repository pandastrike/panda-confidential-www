# Panda Confidential Web Site

## Pug

### Helpers

Helpers are functions that are available from within Pug templates via the `$` property. For example, you can convert a string to Markdown dynamically via `$.markdown`.

Markdown notwithstanding, helpers do not usually generate HTML. Use [Mixins](#mixins) for that instead.

```pug
h2 Description
!= $.markdown(description)
```

| name       | arguments     | returns                                                      |
| ---------- | ------------- | ------------------------------------------------------------ |
| markdown   | string        | HTML rendered from markdown _string_.                        |
| autolink   | value, parent | URL corresponding to _value_ and optional _parent_. See [Generating Links](#generating-links). |
| types      | -             | Dictionary of types.                                         |
| type       | key           | Dictionary of properties and methods for the type referenced by _key_. |
| functions  | -             | Dictionary of functions.                                     |
| properties | -             | Dictionary of (top-level) properties.                        |
| properties | key, scope    | Dictionary of properties for the type referenced by _key_ and the given _scope_ (class or instance) |
| methods    | key, scope    | Dictionary of methods for the type referenced by _key_ and the given _scope_ (class or instance). |


### Generating Links

The `Site.autolink` helper generates a link based on a string or an object.

> **Site.autolink** value &rarr; link

| variable | type                 | description                                                 |
| -------- | -------------------- | ----------------------------------------------------------- |
| value    | `String` or `Object` | The value for which we want to find the corresponding link. |
| link     | URL                  | The link corresponding to the value.                        |

Links may come from two sources:

- The `links.yaml` file, which has precedence.
- The YAML files corresponding to content objects.

Each content object is added to the link dictionary at least once using it's *canonical reference* as the key. It will also be added using it's name as a key, if an entry doesn't already exist for that key. Thus, you may look up the link to a content object using either name or reference.

The canonical reference is determined by either setting it explicitly within the YAML file or deriving it from the last two components for the corresponding _logical_, or destination path. For example, for the content object for the `encrypt` function, this would be `functions/encrypt` because these are the last two components of the destination path.



| If the content object has… | the key |      |
| -------------------------- | ------- | ---- |
| a `fragment` property      |         |      |
|                            |         |      |



#### Converting a value to a link …

| If the value is a … | and …                                                        | return …                           |
| ------------------- | ------------------------------------------------------------ | ---------------------------------- |
| string              | is a URL (begins with a `/` or with `http://` or `https://`) | the value itself                   |
|                     | has an entry in the link dictionary                          | the dictionary entry               |
| object              | with a `reference` property                                  | the corresponding dictionary entry |

If no rules apply, `autolink` returns `#broken`.

#### Combining a value with a base URL …

| If the value is a … | and …                                                 | return …                                                     |
| ------------------- | ----------------------------------------------------- | ------------------------------------------------------------ |
| string              | is a document fragment identifier (begins with a `#`) | the URL that results from appending the value to the base URL |
|                     | is a relative path or path component                  | the URL that results from joining the value to the base URL  |
| object              | has a `link` property                                 | the URL that results from combining the `link` property with the base URL |
|                     | has a `key` property                                  | the URL that results from combining the `key` property with the base URL |

If no rules apply, the result of the combination is `#`.

#### Examples

In the following example, `type` is an object describing a type with a `name` property.

| code                                             | result                                    |
| ------------------------------------------------ | ----------------------------------------- |
| `$.autolink("Declaration")`                      | `/api/types/declaration`                  |
| `$.autolink("Declaration", "#instance-methods")` | `/api/types/declaration#instance-methods` |
| `$.autolink("Declaration", "from")`              | `/api/types/declaration/from`             |
| `$.autolink(type, "from")`                       | `/api/types/declaration/from`             |



### Mixins



| name           | arguments | generates… |
| -------------- | ----------- | -------------- |
| css | source, repo, version, path | CSS link tags for the default CDN. |
| js | source, repo, version, path | JS script tags for default CDN. |
| embed | title, url, description | meta tags for social embedding. |
| highlighting | theme="prism" | JS and CSS tags for Prism highlighting. |
| icon | name, style="regular" | Font Awesome SVG. |
| autolink | keys, &block | anchor using `$.autolink`. Wraps block if provided. |
| breadcrumbs | crumbs, here | breadcrumb menu from an array, using `autolink` to generate links.. If _here_ is true, the last item will be a span tag instead of a link. |
| toc | entries, current | unordered list of links from an array, using `autolink` to generate links. If the entry's key matches _current_, the item will be enclosed within a span tag instead of a link. |
| type | &block | article describing a type as defined by template variables. Embeds block if provided. |
| function | &block | article describing a function as defined by template variables. Embeds block if provided. |
| property | &block | article describing a property as defined by template variables. Embeds block if provided. |
| properties | scope | section describing the _scope_ properties for a type defined by template variables. |
| methods | scope | section describing the _scope_ methods for a type defined by template variables. |
| method | &block | article describing a method as defined by template variables. Embeds block if provided. |
| variables | array | section describing arguments to a function. |
| method-variables | array | section describing arguments to a method for the type defined by template variable _type_. |
| signatures | - | section describing the signatures for a function or method, as defined by template variable _signatures_ |

