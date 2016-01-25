USE [KRR-PA-GLB-SERVICE]
GO

/****** Object:  Table [dbo].[scheduler]    Script Date: 25.01.2016 11:55:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[scheduler](
	[id] [int] NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[database] [nvarchar](50) NOT NULL,
	[table] [nvarchar](50) NOT NULL,
	[execute] [nvarchar](max) NOT NULL,
	[enable] [int] NOT NULL CONSTRAINT [DF_scheduler_enable]  DEFAULT ((0)),
	[status] [int] NOT NULL CONSTRAINT [DF_scheduler_status]  DEFAULT ((-9999)),
	[description] [nvarchar](255) NOT NULL,
	[interval] [int] NOT NULL CONSTRAINT [DF_scheduler_interval]  DEFAULT ((60)),
	[timestamp] [int] NOT NULL CONSTRAINT [DF_scheduler_timestamp]  DEFAULT (datediff(second,'1970',getdate())),
	[duration] [int] NOT NULL DEFAULT ((0)),
	[error] [nvarchar](max) NULL,
 CONSTRAINT [PK_scheduler] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [AK_name] UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_scheduler] UNIQUE NONCLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO


