namespace Bloxstrap.Models.APIs.GitHub
{
    public class VersionManifest
    {
        [JsonPropertyName("version")]
        public string Version { get; set; } = null!;

        [JsonPropertyName("versionCode")]
        public int VersionCode { get; set; }

        [JsonPropertyName("releaseName")]
        public string? ReleaseName { get; set; }

        [JsonPropertyName("releaseDate")]
        public string? ReleaseDate { get; set; }

        [JsonPropertyName("downloadUrl")]
        public string? DownloadUrl { get; set; }

        [JsonPropertyName("directWindowsUrl")]
        public string? DirectWindowsUrl { get; set; }

        [JsonPropertyName("directMacUrl")]
        public string? DirectMacUrl { get; set; }
    }
}
