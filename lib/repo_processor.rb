# frozen_string_literal: true
class RepoProcessor
  attr_reader :path, :repo_url

  def initialize(repo_url)
    @path = File.join(Dir.tmpdir, SecureRandom.urlsafe_base64(32))
    @repo_url = repo_url

    @repo = Rugged::Repository.clone_at(repo_url, path)
  end

  def repo_stats
    return [] if @repo.nil?

    files = list_tree
    files.map { |file| file_stats(file) }
  end

  def destroy_repo!
    return if @path.nil?

    FileUtils.rm_rf(path)
    @repo = nil
    @path = nil
  end

  private

  def list_tree(root: @repo&.head&.target&.tree, parent: nil)
    return [] if @repo.nil? || root.nil?

    root.map do |file|
      set_paths(file, parent)
      case file[:type]
      when :tree then [file, list_tree(root: @repo.lookup(file[:oid]), parent: file[:path])]
      when :blob then file
      end
    end.flatten
  end

  def set_paths(file, parent_path)
    file.tap do |f|
      f[:parent_path] = parent_path
      f[:path] = File.join([parent_path, f[:name]].compact)
    end
  end

  def file_stats(file)
    return FileStat.new(file) if file[:type] == :tree

    hunk_groups = Rugged::Blame.new(@repo, file[:path])
                               .group_by { |hunk| hunk[:final_signature][:email] }
    hunk_groups.each do |k, v|
      hunk_groups[k] = v.map { |hunk| hunk[:lines_in_hunk] }.reduce(0, &:+)
    end
    file[:stats] = hunk_groups
    FileStat.new(file)
  end

  def project_name
    URI(repo_url).path.split('/').last
  end

  def root_file
    { name: project_name, path: project_name, parent_path: '', type: :tree }
  end
end
