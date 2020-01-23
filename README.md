# DemeterCop

DemeterCop is a simple tool that let you watch a Ruby object and record which methods and method chains are being called on it.


## Usage

```ruby
class Suspicious
  def action
    ['first', 'second']
  end
end

suspect = Suspicious.new
watched = DemeterCop.watch(suspect) # No need to assign really, as the same object will be returned
suspect == watched # => true

suspect.action.last.length
DemeterCop.report
```

Will return (pretty formatted):

```
{
    Suspicious < Object => {
               [ :action ] => {
            :location => "(irb):21:in `irb_binding'"
        },
        [ :action, :last ] => {
            :location => "(irb):21:in `irb_binding'"
        }
    }
}
```
Where keys (like `[:action, :last]`) are method chains called on the watched object and values are extra information, for example `:location` for source file call location.
