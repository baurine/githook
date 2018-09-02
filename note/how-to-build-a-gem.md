# How a Build a Gem

## References

1. [Step-by-Step Guide to Building Your First Ruby Gem](https://quickleft.com/blog/engineering-lunch-series-step-by-step-guide-to-building-your-first-ruby-gem/)

## Note

### 创建一个 ruby gem 项目

第一步，创建一个 ruby gem 项目，使用 `bundle gem gem_name` 命令。

    bundle gem githook

这样，就会生成一个 githook 的目录，里面是一个 gem 所需的模板代码和目录结构，其实就是一个 gem 的脚手架，就跟 `rails new project_name` 命令一样。

在这个目录里面，有一个 .gemspec 文件，类似 npm 中的 manifest.json，用来描述这个 gem 的名字，作者，说明等。

修改这个 .gemspec 文件，去掉 TODO，填充上自己的内容。

这里面有个 `spec.files` 的属性，它表示最终生成的 .gem 中要包含的文件，把与功能实现无关的文件排除出去，比如测试相关的文件，以减小 .gem 的体积。

另外，正如 `rails new` 新建一个项目后要执行 `bundle` 安装其依赖，这里，我们也要在这个目录中执行 `bundle` 安装依赖。

### 实现 gem

gem 的实现代码在 lib 目录中，lib 目录中有一个与项目同名的文件夹，比如 githook，另外有一个与项目同名的 .rb 文件，比如 githook.rb。

建议把所有实现都放到目录中，顶层的 .rb 文件只用来导出目录中所有的 class 或 module，这样，在其它地方，只需要 require 这个顶层的 githook.rb 就行了。比如我这个项目中的 githook.rb。

    require "rake"
    require "githook/version"
    require "githook/context"
    require "githook/util"
    require "githook/tasks"
    require "githook/config"

    module Githook
      # Your code goes here...
    end

### 写测试

测试文件写在 spec 目录中，暂略。

### 本地打包安装

在正式发布供别人使用之前，我们要先在本地测试一下。

构建打包：

    gem build githook.gemspec

然后会在当前目录下生成相应的 .gem 文件，比如 `git-hook-0.1.7.gem`。

然后我们在本地安装这个 .gem 文件：

    gem install git-hook-0.1.7.gem

测试一下工作是否正常：

    $ githook help

### 发布

一切就绪，我们准备发布。在此之前，我们要先到 Gem 的发布平台 [RubyGem](https://rubygems.org/) 申请账号，获得 API Key，根据[网站上的指示](https://rubygems.org/profile/edit)，在本地生成一个 `~/.gem/credential` 文件，文件里存放你的 API Key。

然后，执行 `rake release` 命令就能完成发布。`rake release` 会完成一系列工作，比如为你的项目打一个名为当前版本号的 tag，并推送远程，本地构建生成 .gem 文件，上传 .gem 文件等。

如果你不想在发布时为 repo 打 tag 等一些事情，只是想把 .gem 文件上传到 RubyGem，那你也可用 `gem build` 来手动构建打包，用 `gem push` 来上传 gem 文件。

    gem build githook.gemspec
    gem push git-hook-0.1.7.gem

用 `rake -T` 查看一下还有什么其它命令：

    > rake -T
    rake build            # Build git-hook-0.1.7.gem into the pkg directory
    rake clean            # Remove any temporary products
    rake clobber          # Remove any generated file
    rake install          # Build and install git-hook-0.1.7.gem into system gems
    rake install:local    # Build and install git-hook-0.1.7.gem into system gems without network access
    rake release[remote]  # Create tag v0.1.7 and build and push git-hook-0.1.7.gem to Rubygems
    rake spec             # Run RSpec code examples

看来也可以用 `rake build` 替代 `gem build`。

### 升级发布

当发现 BUG 或新添加了功能，我们要升级这个 gem 的版本号并重新发布。升级版本号修改 `lib/githook/version.rb` 文件，然后提交代码，本地打包安装测试，一切 OK 后执行 `rake release` 即可。
