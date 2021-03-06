{CompositeDisposable} = require 'atom'
{$, TextEditorView, View} = require 'atom-space-pen-views'

git = require '../git'
StatusView = require '../views/status-view'
BranchListView = require '../views/branch-list-view'

module.exports.gitBranches = ->
  git.cmd
    args: ['branch'],
    stdout: (data) ->
      new BranchListView(data)

class InputView extends View
  @content: ->
    @div =>
      @subview 'branchEditor', new TextEditorView(mini: true, placeholderText: 'New branch name')

  initialize: ->
    @disposables = new CompositeDisposable
    @currentPane = atom.workspace.getActivePane()
    panel = atom.workspace.addModalPanel(item: this)
    panel.show()

    destroy = =>
      panel.destroy()
      @disposables.dispose()
      @currentPane.activate()

    @branchEditor.focus()
    @disposables.add atom.commands.add 'atom-text-editor', 'core:cancel': (event) -> destroy()
    @disposables.add atom.commands.add 'atom-text-editor', 'core:confirm': (event) =>
      editor = @branchEditor.getModel()
      name = editor.getText()
      if name.length > 0
        @createBranch name
        destroy()

  createBranch: (name) ->
    git.cmd
      args: ['checkout', '-b', name],
      stdout: (data) =>
        new StatusView(type: 'success', message: data.toString())
        git.getRepo()?.refreshStatus?()
        @currentPane.activate()

module.exports.newBranch = ->
  new InputView()
